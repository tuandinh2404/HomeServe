import { Router } from "express";

import { pool } from "../db.js";

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
