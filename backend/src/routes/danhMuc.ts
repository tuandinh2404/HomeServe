import { Router } from "express";

import { pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";
// /danh-muc-dv (xem công khai; thêm / sửa / xóa chỉ QUAN_TRI)
// Phụ trách: Tâm. Chi tiết đường dẫn, dữ liệu, mã lỗi: xem api.md.
export const danhMucRouter = Router();

// GET /danh-muc-dv — công khai, xem được trước khi đăng nhập
// Trả: [ { "id": 1, "ten": "Điện", "so_dich_vu": 7 }, ... ]
danhMucRouter.get("/danh-muc-dv", async (_req, res) => {
  const { rows } = await pool.query(
    `SELECT dm.id, dm.ten, COUNT(dv.id)::int AS so_dich_vu
       FROM danh_muc_dv dm
       LEFT JOIN dich_vu dv ON dv.danh_muc_id = dm.id
      GROUP BY dm.id
      ORDER BY dm.id`,
  );
  res.json(rows);
});

// POST / PATCH / DELETE /danh-muc-dv: làm sau khi có middleware chiCho("QUAN_TRI") (bước đăng nhập)
// POST /danh-muc-dv — chỉ quản trị được thêm danh mục
danhMucRouter.post(
  "/danh-muc-dv",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const ten = req.body?.ten;

    if (typeof ten !== "string" || !ten.trim()) {
      throw loi.saiDuLieu("Nhập tên danh mục", "ten");
    }

    if (ten.trim().length > 100) {
      throw loi.saiDuLieu(
        "Tên danh mục không được quá 100 ký tự",
        "ten",
      );
    }

    const { rows } = await pool.query(
      "INSERT INTO danh_muc_dv (ten) VALUES ($1) RETURNING id, ten",
      [ten.trim()],
    );

    res.status(201).json(rows[0]);
  },
);

// Sửa tên danh mục — chỉ quản trị được dùng
danhMucRouter.patch(
  "/danh-muc-dv/:id",
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

    const ten = req.body?.ten;

    if (typeof ten !== "string" || !ten.trim()) {
      throw loi.saiDuLieu("Nhập tên danh mục", "ten");
    }

    if (ten.trim().length > 100) {
      throw loi.saiDuLieu(
        "Tên danh mục không được quá 100 ký tự",
        "ten",
      );
    }

    const { rows } = await pool.query(
      "UPDATE danh_muc_dv SET ten = $1 WHERE id = $2 RETURNING id, ten",
      [ten.trim(), id],
    );

    if (rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy danh mục");
    }

    res.json(rows[0]);
  },
);

// Xóa danh mục — chỉ quản trị được dùng
danhMucRouter.delete(
  "/danh-muc-dv/:id",
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

    const { rows } = await pool.query(
      "DELETE FROM danh_muc_dv WHERE id = $1 RETURNING id",
      [id],
    );

    if (rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy danh mục");
    }

    res.json({ thong_bao: "Đã xóa danh mục", id: rows[0].id });
  },
);