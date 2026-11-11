import { Router } from "express";

import { pool, giaoDich } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const yeuCauRouter = Router();

// Khách hàng tạo yêu cầu sửa chữa.
yeuCauRouter.post(
  "/yeu-cau",
  canDangNhap,
  chiCho("KHACH"),
  async (req, res) => {
    const body = req.body;

    if (!body || typeof body !== "object" || Array.isArray(body)) {
      throw loi.saiDuLieu("Dữ liệu phải là một đối tượng JSON");
    }

    const {
      dich_vu_id,
      khu_vuc_id,
      mo_ta,
      dia_chi,
      thoi_gian_mong_muon,
      anh_url,
      vi_do,
      kinh_do,
    } = body;

    for (const [cot, giaTri] of [
      ["dich_vu_id", dich_vu_id],
      ["khu_vuc_id", khu_vuc_id],
    ] as const) {
      if (
        !Number.isInteger(giaTri) ||
        giaTri <= 0 ||
        giaTri > 2147483647
      ) {
        throw loi.saiDuLieu("ID phải là số nguyên dương", cot);
      }
    }

    for (const [cot, giaTri] of [
      ["mo_ta", mo_ta],
      ["dia_chi", dia_chi],
    ] as const) {
      if (typeof giaTri !== "string" || !giaTri.trim()) {
        throw loi.saiDuLieu("Không được để trống", cot);
      }
    }

    // Yêu cầu thời gian có múi giờ, ví dụ +07:00 hoặc Z.
    if (
      typeof thoi_gian_mong_muon !== "string" ||
      !/(Z|[+-]\d{2}:\d{2})$/i.test(thoi_gian_mong_muon) ||
      !Number.isFinite(Date.parse(thoi_gian_mong_muon))
    ) {
      throw loi.saiDuLieu(
        "Nhập ngày giờ hợp lệ có múi giờ",
        "thoi_gian_mong_muon",
      );
    }

    const thoiGian = new Date(thoi_gian_mong_muon);

    if (thoiGian.getTime() <= Date.now()) {
      throw loi.saiDuLieu(
        "Thời gian mong muốn phải ở tương lai",
        "thoi_gian_mong_muon",
      );
    }

    const coViDo = vi_do !== undefined && vi_do !== null;
    const coKinhDo = kinh_do !== undefined && kinh_do !== null;

    if (coViDo !== coKinhDo) {
      throw loi.saiDuLieu("Cần gửi cả vĩ độ và kinh độ", "vi_do");
    }

    if (
      coViDo &&
      (
        typeof vi_do !== "number" ||
        !Number.isFinite(vi_do) ||
        vi_do < -90 ||
        vi_do > 90
      )
    ) {
      throw loi.saiDuLieu("Vĩ độ phải từ -90 đến 90", "vi_do");
    }

    if (
      coKinhDo &&
      (
        typeof kinh_do !== "number" ||
        !Number.isFinite(kinh_do) ||
        kinh_do < -180 ||
        kinh_do > 180
      )
    ) {
      throw loi.saiDuLieu("Kinh độ phải từ -180 đến 180", "kinh_do");
    }

    let anhUrl: string | null = null;

    if (anh_url !== undefined && anh_url !== null) {
      if (typeof anh_url !== "string") {
        throw loi.saiDuLieu("Đường dẫn ảnh phải là chuỗi", "anh_url");
      }

      let url: URL;

      try {
        url = new URL(anh_url);
      } catch {
        throw loi.saiDuLieu("Đường dẫn ảnh không hợp lệ", "anh_url");
      }

      if (url.protocol !== "https:") {
        throw loi.saiDuLieu("Đường dẫn ảnh phải dùng HTTPS", "anh_url");
      }

      anhUrl = url.href;
    }

    const dichVu = await pool.query(
      "SELECT id FROM dich_vu WHERE id = $1",
      [dich_vu_id],
    );

    if (dichVu.rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy dịch vụ");
    }

    const khuVuc = await pool.query(
      "SELECT id FROM khu_vuc WHERE id = $1",
      [khu_vuc_id],
    );

    if (khuVuc.rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy khu vực");
    }

    const { rows } = await pool.query(
      `INSERT INTO yeu_cau
        (khach_id, dich_vu_id, khu_vuc_id, mo_ta,
         dia_chi, thoi_gian_mong_muon, anh_url, vi_do, kinh_do)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, khach_id, dich_vu_id, khu_vuc_id,
                 mo_ta, dia_chi, thoi_gian_mong_muon,
                 anh_url, vi_do, kinh_do, trang_thai, tao_luc`,
      [
        req.nguoiDung!.id,
        dich_vu_id,
        khu_vuc_id,
        mo_ta.trim(),
        dia_chi.trim(),
        thoiGian.toISOString(),
        anhUrl,
        vi_do ?? null,
        kinh_do ?? null,
      ],
    );

    res.status(201).json(rows[0]);
  },
);

// Khách xem yêu cầu của chính mình, có phân trang.
yeuCauRouter.get(
  "/yeu-cau/cua-toi",
  canDangNhap,
  chiCho("KHACH"),
  async (req, res) => {
    // Đọc tham số phân trang.
    function docSo(
      giaTri: unknown,
      macDinh: number,
      toiDa: number,
      cot: string,
    ): number {
      if (giaTri === undefined) return macDinh;

      if (typeof giaTri !== "string" || !/^\d+$/.test(giaTri)) {
        throw loi.saiDuLieu("Phải là số nguyên dương", cot);
      }

      const so = Number(giaTri);

      if (!Number.isSafeInteger(so) || so < 1 || so > toiDa) {
        throw loi.saiDuLieu(
          `Phải là số nguyên từ 1 đến ${toiDa}`,
          cot,
        );
      }

      return so;
    }

    const trang = docSo(req.query.trang, 1, 2147483647, "trang");
    const soLuong = docSo(req.query.soLuong, 20, 100, "soLuong");
    const boQua = (trang - 1) * soLuong;

    const { rows } = await pool.query(
      `SELECT
         yc.id,
         yc.dich_vu_id,
         dv.ten AS ten_dich_vu,
         yc.khu_vuc_id,
         kv.ten AS ten_khu_vuc,
         yc.mo_ta,
         yc.anh_url,
         yc.dia_chi,
         yc.thoi_gian_mong_muon,
         yc.trang_thai,
         yc.tao_luc
       FROM yeu_cau yc
       JOIN dich_vu dv ON dv.id = yc.dich_vu_id
       JOIN khu_vuc kv ON kv.id = yc.khu_vuc_id
       WHERE yc.khach_id = $1
       ORDER BY yc.tao_luc DESC, yc.id DESC
       LIMIT $2 OFFSET $3`,
      [req.nguoiDung!.id, soLuong, boQua],
    );

    res.json(rows);
  },
);

// Xem chi tiết yêu cầu: chủ đơn, thợ được gán hoặc quản trị.
yeuCauRouter.get(
  "/yeu-cau/:id",
  canDangNhap,
  async (req, res) => {
    const idChuoi = req.params.id;

    if (typeof idChuoi !== "string" || !/^\d+$/.test(idChuoi)) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const id = Number(idChuoi);

    if (!Number.isInteger(id) || id <= 0 || id > 2147483647) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const nguoiDung = req.nguoiDung!;

    const { rows } = await pool.query(
      `SELECT
         yc.id,
         yc.khach_id,
         yc.dich_vu_id,
         dv.ten AS ten_dich_vu,
         yc.khu_vuc_id,
         kv.ten AS ten_khu_vuc,
         yc.mo_ta,
         yc.anh_url,
         yc.dia_chi,
         yc.vi_do,
         yc.kinh_do,
         yc.thoi_gian_mong_muon,
         yc.trang_thai,
         yc.tao_luc,
         pc.tho_id,
         pc.trang_thai AS trang_thai_phan_cong,
         pc.thoi_gian_du_kien_toi,
         nd.ho_ten AS ten_tho,
         nd.anh_dai_dien_url AS anh_tho,
         hs.diem_tb AS diem_tb_tho,
         hs.so_viec AS so_viec_tho
       FROM yeu_cau yc
       JOIN dich_vu dv ON dv.id = yc.dich_vu_id
       JOIN khu_vuc kv ON kv.id = yc.khu_vuc_id
       LEFT JOIN phan_cong pc
         ON pc.yeu_cau_id = yc.id
        AND pc.trang_thai IN ('CHO_THO_NHAN', 'DA_NHAN')
       LEFT JOIN nguoi_dung nd ON nd.id = pc.tho_id
       LEFT JOIN ho_so_tho hs ON hs.nguoi_dung_id = pc.tho_id
       WHERE yc.id = $1`,
      [id],
    );

    const yeuCau = rows[0];

    if (!yeuCau) {
      throw loi.khongTimThay("Không tìm thấy yêu cầu");
    }

    const laQuanTri = nguoiDung.vaiTro === "QUAN_TRI";

    const laChuDon =
      nguoiDung.vaiTro === "KHACH" &&
      yeuCau.khach_id === nguoiDung.id;

    const laThoDuocGan =
      nguoiDung.vaiTro === "THO" &&
      yeuCau.tho_id === nguoiDung.id;

    if (!laQuanTri && !laChuDon && !laThoDuocGan) {
      throw loi.khongDuQuyen();
    }

    // Chỉ đọc báo giá sau khi đã kiểm tra quyền xem đơn.
    const baoGia = await pool.query(
      `SELECT
         id,
         tho_id,
         dich_vu_id,
         hang_muc,
         so_luong,
         don_gia,
         thanh_tien,
         vuot_tran,
         da_xem_xet,
         tao_luc
       FROM bao_gia_chi_tiet
       WHERE yeu_cau_id = $1
       ORDER BY id`,
      [id],
    );

    res.json({
      ...yeuCau,
      bao_gia: baoGia.rows,
    });
  },
);


// Khách hủy yêu cầu của mình khi chưa bắt đầu làm.
yeuCauRouter.patch(
  "/yeu-cau/:id/huy",
  canDangNhap,
  chiCho("KHACH"),
  async (req, res) => {
    const chuoi = req.params.id;

    if (typeof chuoi !== "string" || !/^\d+$/.test(chuoi)) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const id = Number(chuoi);

    if (!Number.isInteger(id) || id <= 0 || id > 2147483647) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const ketQua = await giaoDich(async (client) => {
      const { rows } = await client.query(
        `SELECT id, khach_id, trang_thai
         FROM yeu_cau
         WHERE id = $1
         FOR UPDATE`,
        [id],
      );

      const don = rows[0];

      if (!don) {
        throw loi.khongTimThay("Không tìm thấy yêu cầu");
      }

      if (don.khach_id !== req.nguoiDung!.id) {
        throw loi.khongDuQuyen();
      }

      if (don.trang_thai === "HUY") {
        return { id: don.id, trang_thai: "HUY" };
      }

      if (!["CHO_NHAN", "DA_NHAN"].includes(don.trang_thai)) {
        throw loi.xungDot(
          "Chỉ được hủy khi yêu cầu chưa bắt đầu làm",
        );
      }

      const capNhat = await client.query(
        `UPDATE yeu_cau
         SET trang_thai = 'HUY'
         WHERE id = $1
         RETURNING id, trang_thai`,
        [id],
      );

      return capNhat.rows[0];
    });

    res.json(ketQua);
  },
);