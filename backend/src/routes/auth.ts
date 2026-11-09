import { Router } from "express";
import bcrypt from "bcryptjs";

import { pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, taoToken, type VaiTro } from "../middleware/xacThuc.js";

// /auth/dang-ky, /auth/dang-nhap, /auth/toi
// Phụ trách: Tuấn. Chi tiết đường dẫn, dữ liệu, mã lỗi: xem api.md.
export const authRouter = Router();

// Độ "nặng" khi băm mật khẩu: 10 vòng mất khoảng 0,1 giây. Tăng thì an toàn hơn nhưng chậm hơn.
const VONG_BAM = 10;
const MAT_KHAU_TOI_THIEU = 6;
const EMAIL_HOP_LE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Hash giả để so sánh khi email không tồn tại, giúp thời gian trả lời như nhau
// → người ngoài không đo thời gian để dò email nào đã đăng ký.
const HASH_GIA = bcrypt.hashSync("khong-co-tai-khoan-nay", VONG_BAM);

function chuoi(giaTri: unknown): string {
  return typeof giaTri === "string" ? giaTri.trim() : "";
}

// POST /auth/dang-ky — công khai. Luôn tạo tài khoản KHACH (bỏ qua vai_tro app gửi lên).
// Gửi: { "email", "mat_khau", "ho_ten", "sdt" }  →  201 { "id", "email", "ho_ten", "vai_tro" }
authRouter.post("/auth/dang-ky", async (req, res) => {
  const email = chuoi(req.body?.email).toLowerCase();
  const matKhau = typeof req.body?.mat_khau === "string" ? req.body.mat_khau : "";
  const hoTen = chuoi(req.body?.ho_ten);
  const sdt = chuoi(req.body?.sdt) || null;

  if (!email) throw loi.saiDuLieu("Nhập email", "email");
  if (!EMAIL_HOP_LE.test(email)) throw loi.saiDuLieu("Email không đúng định dạng", "email");
  if (matKhau.length < MAT_KHAU_TOI_THIEU) {
    throw loi.saiDuLieu(`Mật khẩu phải có ít nhất ${MAT_KHAU_TOI_THIEU} ký tự`, "mat_khau");
  }
  if (!hoTen) throw loi.saiDuLieu("Nhập họ tên", "ho_ten");

  const hash = await bcrypt.hash(matKhau, VONG_BAM);
  try {
    const { rows } = await pool.query(
      `INSERT INTO nguoi_dung (email, mat_khau_hash, ho_ten, sdt, vai_tro)
       VALUES ($1, $2, $3, $4, 'KHACH')
       RETURNING id, email, ho_ten, vai_tro`,
      [email, hash, hoTen, sdt],
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    // 23505 = trùng UNIQUE (email). Báo riêng để app hiện lỗi đúng ô email.
    if ((e as { code?: string }).code === "23505") throw loi.xungDot("Email đã được đăng ký", "email");
    throw e;
  }
});

// POST /auth/dang-nhap — công khai.
// Gửi: { "email", "mat_khau" }  →  200 { "token", "nguoi_dung": { "id", "ho_ten", "vai_tro" } }
authRouter.post("/auth/dang-nhap", async (req, res) => {
  const email = chuoi(req.body?.email).toLowerCase();
  const matKhau = typeof req.body?.mat_khau === "string" ? req.body.mat_khau : "";
  if (!email) throw loi.saiDuLieu("Nhập email", "email");
  if (!matKhau) throw loi.saiDuLieu("Nhập mật khẩu", "mat_khau");

  const { rows } = await pool.query(
    "SELECT id, ho_ten, vai_tro, mat_khau_hash FROM nguoi_dung WHERE email = $1",
    [email],
  );
  const nd = rows[0];
  const dung = await bcrypt.compare(matKhau, nd ? nd.mat_khau_hash : HASH_GIA);

  // Sai email hay sai mật khẩu đều cùng một câu, để không lộ email nào đã đăng ký (api.md)
  if (!nd || !dung) throw loi.chuaDangNhap("Email hoặc mật khẩu không đúng");

  const token = taoToken({ id: nd.id, vaiTro: nd.vai_tro as VaiTro });
  res.json({ token, nguoi_dung: { id: nd.id, ho_ten: nd.ho_ten, vai_tro: nd.vai_tro } });
});

// GET /auth/toi — cần đăng nhập. App gọi khi mở lên để biết token còn dùng được không.
// → 200 { "id", "email", "ho_ten", "sdt", "vai_tro" }
authRouter.get("/auth/toi", canDangNhap, async (req, res) => {
  const { rows } = await pool.query(
    "SELECT id, email, ho_ten, sdt, vai_tro FROM nguoi_dung WHERE id = $1",
    [req.nguoiDung!.id],
  );
  // Tài khoản đã bị xóa mà token còn hạn → coi như hết phiên
  if (rows.length === 0) throw loi.chuaDangNhap();
  res.json(rows[0]);
});
