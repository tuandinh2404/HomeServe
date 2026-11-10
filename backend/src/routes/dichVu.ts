import { Router } from "express";

import { pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";
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


// Thêm dịch vụ — chỉ quản trị được dùng
dichVuRouter.post(
  "/dich-vu",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const {
      danh_muc_id,
      ten,
      mo_ta,
      don_vi,
      gia_san,
      gia_tran,
    } = req.body ?? {};

    if (
      !Number.isInteger(danh_muc_id) ||
      danh_muc_id <= 0 ||
      danh_muc_id > 2147483647
    ) {
      throw loi.saiDuLieu(
        "Danh mục phải là ID số nguyên dương",
        "danh_muc_id",
      );
    }

    if (
      typeof ten !== "string" ||
      !ten.trim() ||
      ten.trim().length > 150
    ) {
      throw loi.saiDuLieu(
        "Tên dịch vụ phải có từ 1 đến 150 ký tự",
        "ten",
      );
    }

    if (
      typeof don_vi !== "string" ||
      !don_vi.trim() ||
      don_vi.trim().length > 20
    ) {
      throw loi.saiDuLieu(
        "Đơn vị phải có từ 1 đến 20 ký tự",
        "don_vi",
      );
    }

    if (
      mo_ta !== undefined &&
      mo_ta !== null &&
      typeof mo_ta !== "string"
    ) {
      throw loi.saiDuLieu("Mô tả phải là chuỗi", "mo_ta");
    }

    if (
      !Number.isInteger(gia_san) ||
      gia_san <= 0 ||
      gia_san > 2147483647
    ) {
      throw loi.saiDuLieu(
        "Giá sàn phải là số nguyên dương không quá 2147483647",
        "gia_san",
      );
    }

    if (
      !Number.isInteger(gia_tran) ||
      gia_tran < gia_san ||
      gia_tran > 2147483647
    ) {
      throw loi.saiDuLieu(
        "Giá trần phải là số nguyên, từ giá sàn đến 2147483647",
        "gia_tran",
      );
    }

    const danhMuc = await pool.query(
      "SELECT id FROM danh_muc_dv WHERE id = $1",
      [danh_muc_id],
    );

    if (danhMuc.rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy danh mục");
    }

    const { rows } = await pool.query(
      `INSERT INTO dich_vu
        (danh_muc_id, ten, mo_ta, don_vi, gia_san, gia_tran)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, danh_muc_id, ten, mo_ta,
                 don_vi, gia_san, gia_tran`,
      [
        danh_muc_id,
        ten.trim(),
        typeof mo_ta === "string" ? mo_ta.trim() : null,
        don_vi.trim(),
        gia_san,
        gia_tran,
      ],
    );

    res.status(201).json(rows[0]);
  },
);

// Sửa dịch vụ — chỉ quản trị được dùng
dichVuRouter.patch(
  "/dich-vu/:id",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const id = soNguyenDuong(req.params.id);

    if (id === null) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const body = req.body;

    if (!body || typeof body !== "object" || Array.isArray(body)) {
      throw loi.saiDuLieu("Dữ liệu phải là một đối tượng JSON");
    }

    // Chỉ cho sửa các trường trong danh sách này.
    const cotChoPhep = [
      "danh_muc_id",
      "ten",
      "mo_ta",
      "don_vi",
      "gia_san",
      "gia_tran",
    ];

    const cacCot = Object.keys(body);

    if (cacCot.length === 0) {
      throw loi.saiDuLieu("Cần nhập ít nhất một trường để sửa");
    }

    for (const cot of cacCot) {
      if (!cotChoPhep.includes(cot)) {
        throw loi.saiDuLieu("Trường không được phép sửa", cot);
      }
    }

    // Kiểm tra các trường dạng số khi được gửi lên.
    for (const cot of ["danh_muc_id", "gia_san", "gia_tran"]) {
      if (Object.hasOwn(body, cot)) {
        const giaTri = body[cot];

        if (
          !Number.isInteger(giaTri) ||
          giaTri <= 0 ||
          giaTri > 2147483647
        ) {
          throw loi.saiDuLieu(
            "Phải là số nguyên dương không quá 2147483647",
            cot,
          );
        }
      }
    }

    // Kiểm tra tên và đơn vị khi được gửi lên.
    for (const cot of ["ten", "don_vi"]) {
      if (Object.hasOwn(body, cot)) {
        const gioiHan = cot === "ten" ? 150 : 20;
        const giaTri = body[cot];

        if (
          typeof giaTri !== "string" ||
          !giaTri.trim() ||
          giaTri.trim().length > gioiHan
        ) {
          throw loi.saiDuLieu(
            `Phải có từ 1 đến ${gioiHan} ký tự`,
            cot,
          );
        }
      }
    }

    if (
      Object.hasOwn(body, "mo_ta") &&
      body.mo_ta !== null &&
      typeof body.mo_ta !== "string"
    ) {
      throw loi.saiDuLieu("Mô tả phải là chuỗi hoặc null", "mo_ta");
    }

    // Tên cột chỉ lấy từ danh sách đã kiểm tra phía trên.
    // Giá trị người dùng luôn truyền qua $1, $2...
    const giaTri = cacCot.map((cot) =>
      typeof body[cot] === "string" ? body[cot].trim() : body[cot],
    );

    const cauSet = cacCot
      .map((cot, viTri) => `${cot} = $${viTri + 1}`)
      .join(", ");

    giaTri.push(id);

    const { rows } = await pool.query(
      `UPDATE dich_vu
          SET ${cauSet}
        WHERE id = $${giaTri.length}
        RETURNING id, danh_muc_id, ten, mo_ta,
                  don_vi, gia_san, gia_tran`,
      giaTri,
    );

    if (rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy dịch vụ");
    }

    res.json(rows[0]);
  },
);


// Xóa dịch vụ — chỉ quản trị được dùng
dichVuRouter.delete(
  "/dich-vu/:id",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const id = soNguyenDuong(req.params.id);

    if (id === null) {
      throw loi.saiDuLieu("ID phải là số nguyên dương", "id");
    }

    const { rows } = await pool.query(
      "DELETE FROM dich_vu WHERE id = $1 RETURNING id",
      [id],
    );

    if (rows.length === 0) {
      throw loi.khongTimThay("Không tìm thấy dịch vụ");
    }

    res.json({
      thong_bao: "Đã xóa dịch vụ",
      id: rows[0].id,
    });
  },
);