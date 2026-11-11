import { Router } from "express";

import { pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const hoSoThoRouter = Router();

// Quản trị xem hồ sơ thợ, có thể lọc theo trạng thái duyệt.
hoSoThoRouter.get(
  "/ho-so-tho",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const trangThai = req.query.trangThai;

    if (
      trangThai !== undefined &&
      (
        typeof trangThai !== "string" ||
        !["CHO_DUYET", "DA_DUYET", "TU_CHOI"].includes(trangThai)
      )
    ) {
      throw loi.saiDuLieu(
        "Trạng thái phải là CHO_DUYET, DA_DUYET hoặc TU_CHOI",
        "trangThai",
      );
    }

    const { rows } = await pool.query(
      `SELECT
         hs.id,
         hs.nguoi_dung_id,
         nd.ho_ten,
         nd.email,
         nd.sdt,
         nd.anh_dai_dien_url,
         hs.nghe_id,
         dm.ten AS ten_nghe,
         hs.kinh_nghiem_nam,
         hs.chung_chi_url,
         hs.giay_to_url,
         hs.khu_vuc_id,
         kv.ten AS ten_khu_vuc,
         hs.trang_thai_duyet,
         hs.ly_do_tu_choi,
         hs.diem_tb,
         hs.so_viec,
         hs.tao_luc
       FROM ho_so_tho hs
       JOIN nguoi_dung nd ON nd.id = hs.nguoi_dung_id
       JOIN danh_muc_dv dm ON dm.id = hs.nghe_id
       JOIN khu_vuc kv ON kv.id = hs.khu_vuc_id
       WHERE ($1::text IS NULL OR hs.trang_thai_duyet = $1)
       ORDER BY hs.tao_luc DESC, hs.id DESC`,
      [trangThai ?? null],
    );

    res.json(rows);
  },
);


// Quản trị duyệt hoặc từ chối hồ sơ thợ.
hoSoThoRouter.patch(
  "/ho-so-tho/:id/duyet",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const idChuoi = req.params.id;

    if (typeof idChuoi !== "string" || !/^\d+$/.test(idChuoi)) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const id = Number(idChuoi);

    if (!Number.isInteger(id) || id <= 0 || id > 2147483647) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const trangThai = req.body?.trang_thai_duyet;
    const lyDo = req.body?.ly_do_tu_choi;

    if (trangThai !== "DA_DUYET" && trangThai !== "TU_CHOI") {
      throw loi.saiDuLieu(
        "Chỉ được chọn DA_DUYET hoặc TU_CHOI",
        "trang_thai_duyet",
      );
    }

    if (
      lyDo !== undefined &&
      lyDo !== null &&
      typeof lyDo !== "string"
    ) {
      throw loi.saiDuLieu(
        "Lý do từ chối phải là chuỗi",
        "ly_do_tu_choi",
      );
    }

    if (
      trangThai === "TU_CHOI" &&
      (typeof lyDo !== "string" || !lyDo.trim())
    ) {
      throw loi.saiDuLieu(
        "Cần nhập lý do từ chối",
        "ly_do_tu_choi",
      );
    }

    // Chỉ thay đổi hồ sơ đang chờ duyệt.
    const { rows } = await pool.query(
      `UPDATE ho_so_tho
          SET trang_thai_duyet = $1,
              ly_do_tu_choi = $2
        WHERE id = $3
          AND trang_thai_duyet = 'CHO_DUYET'
        RETURNING id, nguoi_dung_id, nghe_id,
                  kinh_nghiem_nam, chung_chi_url, giay_to_url,
                  khu_vuc_id, trang_thai_duyet, ly_do_tu_choi,
                  diem_tb, so_viec, tao_luc`,
      [
        trangThai,
        trangThai === "TU_CHOI" ? lyDo.trim() : null,
        id,
      ],
    );

    if (rows.length === 0) {
      const hoSo = await pool.query(
        "SELECT id FROM ho_so_tho WHERE id = $1",
        [id],
      );

      if (hoSo.rows.length === 0) {
        throw loi.khongTimThay("Không tìm thấy hồ sơ thợ");
      }

      throw loi.xungDot("Hồ sơ không còn ở trạng thái chờ duyệt");
    }

    res.json(rows[0]);
  },
);


// Thợ gửi hoặc cập nhật hồ sơ của chính mình.
hoSoThoRouter.post(
  "/tho/ho-so",
  canDangNhap,
  chiCho("THO"),
  async (req, res) => {
    const body = req.body;

    if (!body || typeof body !== "object" || Array.isArray(body)) {
      throw loi.saiDuLieu("Dữ liệu phải là một đối tượng JSON");
    }

    const {
      nghe_id,
      khu_vuc_id,
      kinh_nghiem_nam,
      chung_chi_url,
      giay_to_url,
    } = body;

    // Nghề và khu vực phải là ID hợp lệ.
    for (const [cot, giaTri] of [
      ["nghe_id", nghe_id],
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

    if (
      !Number.isInteger(kinh_nghiem_nam) ||
      kinh_nghiem_nam < 0 ||
      kinh_nghiem_nam > 32767
    ) {
      throw loi.saiDuLieu(
        "Số năm kinh nghiệm phải là số nguyên từ 0 đến 32767",
        "kinh_nghiem_nam",
      );
    }

    // Chấp nhận URL HTTPS hoặc bỏ trống.
    function docUrl(giaTri: unknown, cot: string): string | null {
      if (giaTri === undefined || giaTri === null || giaTri === "") {
        return null;
      }

      if (typeof giaTri !== "string") {
        throw loi.saiDuLieu("Đường dẫn phải là chuỗi", cot);
      }

      let url: URL;

      try {
        url = new URL(giaTri.trim());
      } catch {
        throw loi.saiDuLieu("Đường dẫn không hợp lệ", cot);
      }

      if (url.protocol !== "https:") {
        throw loi.saiDuLieu("Đường dẫn phải bắt đầu bằng https://", cot);
      }

      return url.href;
    }

    const chungChi = docUrl(chung_chi_url, "chung_chi_url");
    const giayTo = docUrl(giay_to_url, "giay_to_url");

    const nghe = await pool.query(
      "SELECT id FROM danh_muc_dv WHERE id = $1",
      [nghe_id],
    );

    if (nghe.rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy nghề đã chọn");
    }

    const khuVuc = await pool.query(
      "SELECT id FROM khu_vuc WHERE id = $1",
      [khu_vuc_id],
    );

    if (khuVuc.rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy khu vực đã chọn");
    }

    // Lấy ID từ token, không lấy ID người dùng do app gửi lên.
    const nguoiDungId = req.nguoiDung!.id;

    const { rows } = await pool.query(
      `INSERT INTO ho_so_tho
        (nguoi_dung_id, nghe_id, khu_vuc_id,
         kinh_nghiem_nam, chung_chi_url, giay_to_url)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (nguoi_dung_id)
       DO UPDATE SET
         nghe_id = EXCLUDED.nghe_id,
         khu_vuc_id = EXCLUDED.khu_vuc_id,
         kinh_nghiem_nam = EXCLUDED.kinh_nghiem_nam,
         chung_chi_url = EXCLUDED.chung_chi_url,
         giay_to_url = EXCLUDED.giay_to_url,
         trang_thai_duyet = 'CHO_DUYET',
         ly_do_tu_choi = NULL
       RETURNING id, nguoi_dung_id, nghe_id, khu_vuc_id,
                 kinh_nghiem_nam, chung_chi_url, giay_to_url,
                 trang_thai_duyet, ly_do_tu_choi,
                 diem_tb, so_viec, tao_luc`,
      [
        nguoiDungId,
        nghe_id,
        khu_vuc_id,
        kinh_nghiem_nam,
        chungChi,
        giayTo,
      ],
    );

    res.status(200).json(rows[0]);
  },
);