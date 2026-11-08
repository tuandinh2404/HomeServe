import { Router } from "express";

import { pool } from "../db.js";
import { loi } from "../loi.js";

// /dich-vu, /dich-vu/:id/bang-gia (giá sàn, giá trần)
// Phụ trách: Tâm. Chi tiết đường dẫn, dữ liệu, mã lỗi: xem api.md.
export const dichVuRouter = Router();

// Đọc số nguyên dương từ chuỗi (tham số URL). Sai thì trả null.
function soNguyenDuong(chuoi: unknown): number | null {
  if (typeof chuoi !== "string" || !/^\d+$/.test(chuoi)) return null;
  const so = Number(chuoi);
  return so > 0 && so <= 2147483647 ? so : null;
}

// GET /dich-vu?danhMucId=1 — công khai. Không truyền danhMucId thì trả tất cả.
// Trả: [ { "id", "danh_muc_id", "ten", "gia_san", "gia_tran", "don_vi" }, ... ]
dichVuRouter.get("/dich-vu", async (req, res) => {
  const thamSo = req.query.danhMucId;
  if (thamSo === undefined) {
    const { rows } = await pool.query(
      "SELECT id, danh_muc_id, ten, gia_san, gia_tran, don_vi FROM dich_vu ORDER BY danh_muc_id, id",
    );
    res.json(rows);
    return;
  }
  const danhMucId = soNguyenDuong(thamSo);
  if (danhMucId === null) throw loi.saiDuLieu("danhMucId phải là số nguyên dương", "danhMucId");

  const { rows } = await pool.query(
    "SELECT id, danh_muc_id, ten, gia_san, gia_tran, don_vi FROM dich_vu WHERE danh_muc_id = $1 ORDER BY id",
    [danhMucId],
  );
  res.json(rows);
});

// GET /dich-vu/:id/bang-gia — công khai. Bảng giá tham chiếu của 1 dịch vụ.
// Trả: { "id", "ten", "mo_ta", "gia_san", "gia_tran", "don_vi", "danh_muc": { "id", "ten" } }
dichVuRouter.get("/dich-vu/:id/bang-gia", async (req, res) => {
  const id = soNguyenDuong(req.params.id);
  if (id === null) throw loi.khongTimThay("Không tìm thấy dịch vụ");

  const { rows } = await pool.query(
    `SELECT dv.id, dv.ten, dv.mo_ta, dv.gia_san, dv.gia_tran, dv.don_vi,
            json_build_object('id', dm.id, 'ten', dm.ten) AS danh_muc
       FROM dich_vu dv
       JOIN danh_muc_dv dm ON dm.id = dv.danh_muc_id
      WHERE dv.id = $1`,
    [id],
  );
  if (rows.length === 0) throw loi.khongTimThay("Không tìm thấy dịch vụ");
  res.json(rows[0]);
});
