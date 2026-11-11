import { Router } from "express";

import { giaoDich } from "../db.js";
import { LoiApi, loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const thanhToanRouter = Router();

thanhToanRouter.post(
  "/thanh-toan",
  canDangNhap,
  chiCho("KHACH"),
  async (req, res) => {
    const { yeu_cau_id, hinh_thuc } = req.body ?? {};
    const khachId = req.nguoiDung!.id;

    if (
      !Number.isInteger(yeu_cau_id) ||
      yeu_cau_id <= 0 ||
      yeu_cau_id > 2147483647
    ) {
      throw loi.saiDuLieu("Mã yêu cầu phải là số nguyên dương", "yeu_cau_id");
    }

    if (hinh_thuc !== "TIEN_MAT" && hinh_thuc !== "CHUYEN_KHOAN") {
      throw loi.saiDuLieu(
        "Chọn TIEN_MAT hoặc CHUYEN_KHOAN",
        "hinh_thuc",
      );
    }

    const ketQua = await giaoDich(async (client) => {
      // Khóa yêu cầu trong lúc thanh toán để tránh xử lý hai lần.
      const { rows: [yeuCau] } = await client.query(
        `SELECT id, trang_thai
         FROM yeu_cau
         WHERE id = $1 AND khach_id = $2
         FOR UPDATE`,
        [yeu_cau_id, khachId],
      );

      if (!yeuCau) {
        throw loi.khongTimThay("Không tìm thấy yêu cầu của bạn");
      }

      // Nếu khách gửi lại cùng yêu cầu, trả kết quả đã lưu.
      const { rows: [daThanhToan] } = await client.query(
        `SELECT * FROM thanh_toan WHERE yeu_cau_id = $1`,
        [yeu_cau_id],
      );

      if (daThanhToan) {
        if (daThanhToan.hinh_thuc !== hinh_thuc) {
          throw loi.xungDot("Yêu cầu đã thanh toán bằng hình thức khác");
        }

        return { moi: false, thanhToan: daThanhToan };
      }

      if (yeuCau.trang_thai !== "DANG_LAM") {
        throw loi.xungDot("Chỉ thanh toán yêu cầu đang làm");
      }

      const { rows: [baoGia] } = await client.query(
        `SELECT COALESCE(SUM(bg.thanh_tien), 0) AS tong_tien
         FROM bao_gia_chi_tiet bg
         JOIN phan_cong pc
           ON pc.yeu_cau_id = bg.yeu_cau_id AND pc.tho_id = bg.tho_id
         WHERE bg.yeu_cau_id = $1 AND pc.trang_thai = 'DA_NHAN'`,
        [yeu_cau_id],
      );

      const tongTien = Number(baoGia.tong_tien);

      if (tongTien === 0) {
        throw loi.xungDot("Yêu cầu chưa có báo giá để thanh toán");
      }

      if (!Number.isSafeInteger(tongTien) || tongTien > 2147483647) {
        throw loi.xungDot("Tổng tiền vượt mức cơ sở dữ liệu có thể lưu");
      }

      const { rows: [cauHinh] } = await client.query(
        `SELECT gia_tri FROM cau_hinh WHERE khoa = 'ti_le_hoa_hong'`,
      );

      const tiLe = cauHinh?.gia_tri?.trim();

      if (typeof tiLe !== "string" || !/^(0(?:\.\d{1,3})?|1(?:\.0{1,3})?)$/.test(tiLe)) {
        throw new LoiApi(500, "Cấu hình tỷ lệ hoa hồng chưa hợp lệ");
      }

      const { rows: [thanhToan] } = await client.query(
        `INSERT INTO thanh_toan
           (yeu_cau_id, tong_tien, ti_le_hoa_hong, hoa_hong_san, hinh_thuc)
         VALUES ($1, $2::integer, $3::numeric,
                 ROUND($2::integer * $3::numeric)::integer, $4)
         RETURNING *`,
        [yeu_cau_id, tongTien, tiLe, hinh_thuc],
      );

      await client.query(
        `UPDATE yeu_cau SET trang_thai = 'HOAN_TAT' WHERE id = $1`,
        [yeu_cau_id],
      );

      return { moi: true, thanhToan };
    });

    res.status(ketQua.moi ? 201 : 200).json(ketQua.thanhToan);
  },
);