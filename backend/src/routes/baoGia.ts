import { Router } from "express";

import { giaoDich, pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const baoGiaRouter = Router();

const SO_NGUYEN_TOI_DA = 2147483647;

function laSoNguyenDuong(giaTri: unknown): giaTri is number {
  return (
    typeof giaTri === "number" &&
    Number.isInteger(giaTri) &&
    giaTri > 0 &&
    giaTri <= SO_NGUYEN_TOI_DA
  );
}

// Thợ thêm một hạng mục báo giá cho việc mình đang làm.
baoGiaRouter.post(
  "/bao-gia-chi-tiet",
  canDangNhap,
  chiCho("THO"),
  async (req, res) => {
    const { yeu_cau_id, dich_vu_id, hang_muc, so_luong, don_gia } =
      req.body ?? {};
    const thoId = req.nguoiDung!.id;

    for (const [truong, giaTri] of [
      ["yeu_cau_id", yeu_cau_id],
      ["dich_vu_id", dich_vu_id],
      ["so_luong", so_luong],
      ["don_gia", don_gia],
    ] as const) {
      if (!laSoNguyenDuong(giaTri)) {
        throw loi.saiDuLieu("Giá trị phải là số nguyên dương", truong);
      }
    }

    if (typeof hang_muc !== "string") {
      throw loi.saiDuLieu("Hạng mục phải là chữ", "hang_muc");
    }

    const tenHangMuc = hang_muc.trim();
    if (!tenHangMuc || tenHangMuc.length > 200) {
      throw loi.saiDuLieu("Hạng mục phải dài từ 1 đến 200 ký tự", "hang_muc");
    }

    if (so_luong * don_gia > SO_NGUYEN_TOI_DA) {
      throw loi.saiDuLieu("Thành tiền vượt mức cơ sở dữ liệu có thể lưu");
    }

    const baoGia = await giaoDich(async (client) => {
      const { rows: [yeuCau] } = await client.query(
        `SELECT yc.trang_thai
         FROM yeu_cau yc
         JOIN phan_cong pc ON pc.yeu_cau_id = yc.id
         WHERE yc.id = $1
           AND pc.tho_id = $2
           AND pc.trang_thai = 'DA_NHAN'
         FOR UPDATE OF yc`,
        [yeu_cau_id, thoId],
      );

      if (!yeuCau) {
        throw loi.khongTimThay("Không tìm thấy công việc bạn đã nhận");
      }

      if (yeuCau.trang_thai !== "DANG_LAM") {
        throw loi.xungDot("Chỉ được thêm báo giá khi yêu cầu đang làm");
      }

      const { rows: [ketQua] } = await client.query(
        `INSERT INTO bao_gia_chi_tiet
           (yeu_cau_id, tho_id, dich_vu_id, hang_muc, so_luong, don_gia, vuot_tran)
         SELECT $1, $2, dv.id, $4, $5, $6::integer, $6::integer > dv.gia_tran
         FROM dich_vu dv
         WHERE dv.id = $3
         RETURNING *`,
        [yeu_cau_id, thoId, dich_vu_id, tenHangMuc, so_luong, don_gia],
      );

      if (!ketQua) {
        throw loi.khongTimThay("Không tìm thấy dịch vụ của hạng mục");
      }

      return ketQua;
    });

    res.status(201).json(baoGia);
  },
);

// Quản trị xem báo giá. Mặc định lấy các dòng vượt trần và chưa xem xét.
baoGiaRouter.get(
  "/bao-gia-chi-tiet",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const vuotTran = req.query.vuotTran ?? "true";
    const daXemXet = req.query.daXemXet ?? "false";

    if (vuotTran !== "true" && vuotTran !== "false") {
      throw loi.saiDuLieu("Chỉ nhận true hoặc false", "vuotTran");
    }

    if (daXemXet !== "true" && daXemXet !== "false") {
      throw loi.saiDuLieu("Chỉ nhận true hoặc false", "daXemXet");
    }

    const { rows } = await pool.query(
      `SELECT bg.*, dv.ten AS ten_dich_vu, dv.gia_tran
       FROM bao_gia_chi_tiet bg
       JOIN dich_vu dv ON dv.id = bg.dich_vu_id
       WHERE bg.vuot_tran = $1 AND bg.da_xem_xet = $2
       ORDER BY bg.tao_luc DESC, bg.id DESC`,
      [vuotTran === "true", daXemXet === "true"],
    );

    res.json(rows);
  },
);

// Quản trị đánh dấu đã xem xét báo giá vượt trần.
baoGiaRouter.patch(
  "/bao-gia-chi-tiet/:id/xem-xet",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const id = Number(req.params.id);

    if (!laSoNguyenDuong(id)) {
      throw loi.saiDuLieu("Mã báo giá phải là số nguyên dương", "id");
    }

    const { rows: [baoGia] } = await pool.query(
      `UPDATE bao_gia_chi_tiet
       SET da_xem_xet = true,
           xem_xet_boi = $2,
           xem_xet_luc = now()
       WHERE id = $1 AND vuot_tran = true AND da_xem_xet = false
       RETURNING *`,
      [id, req.nguoiDung!.id],
    );

    if (!baoGia) {
      throw loi.xungDot("Báo giá không có trong danh sách cần xem xét");
    }

    res.json(baoGia);
  },
);