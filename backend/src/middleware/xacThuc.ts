import type { RequestHandler } from "express";
import jwt from "jsonwebtoken";

import { loi } from "../loi.js";

// Vai trò viết y hệt api.md và CHECK trong schema.sql
export type VaiTro = "KHACH" | "THO" | "QUAN_TRI";

// Người đang gọi API, đọc từ token. Route dùng: req.nguoiDung!.id, req.nguoiDung!.vaiTro
export interface NguoiDungDangNhap {
  id: number;
  vaiTro: VaiTro;
}

// Báo cho TypeScript biết req có thêm trường nguoiDung (do canDangNhap gắn vào)
declare global {
  namespace Express {
    interface Request {
      nguoiDung?: NguoiDungDangNhap;
    }
  }
}

// Token hết hạn sau 7 ngày (api.md). Muốn đổi thì sửa ở đây.
const THOI_HAN_TOKEN = "7d";

function biMat(): string {
  const s = process.env.JWT_SECRET;
  if (!s || s.length < 32) throw new Error("JWT_SECRET thiếu hoặc ngắn hơn 32 ký tự");
  return s;
}

// Tạo token sau khi đăng nhập đúng. Trong token chỉ có id + vai trò, KHÔNG có mật khẩu.
export function taoToken(nguoiDung: NguoiDungDangNhap): string {
  return jwt.sign({ vai_tro: nguoiDung.vaiTro }, biMat(), {
    subject: String(nguoiDung.id),
    expiresIn: THOI_HAN_TOKEN,
    algorithm: "HS256",
  });
}

// Đặt TRƯỚC route cần đăng nhập. Đọc header "Authorization: Bearer <token>".
// Thiếu / sai / hết hạn → 401. Đúng → gắn req.nguoiDung rồi cho đi tiếp.
export const canDangNhap: RequestHandler = (req, _res, next) => {
  const [kieu, token] = (req.headers.authorization ?? "").split(" ");
  if (kieu !== "Bearer" || !token) throw loi.chuaDangNhap();

  let noiDung: jwt.JwtPayload;
  try {
    // algorithms: chỉ chấp nhận HS256, chặn kiểu tấn công đổi thuật toán trong token
    noiDung = jwt.verify(token, biMat(), { algorithms: ["HS256"] }) as jwt.JwtPayload;
  } catch {
    throw loi.chuaDangNhap();
  }
  req.nguoiDung = { id: Number(noiDung.sub), vaiTro: noiDung.vai_tro as VaiTro };
  next();
};

// Đặt SAU canDangNhap. Sai vai trò → 403.
//   router.post("/danh-muc-dv", canDangNhap, chiCho("QUAN_TRI"), async (req, res) => { ... })
//   router.get("/tho/toi/viec", canDangNhap, chiCho("THO"), ...)
//   router.post("/danh-gia", canDangNhap, chiCho("KHACH", "THO"), ...)
export function chiCho(...vaiTroDuocPhep: VaiTro[]): RequestHandler {
  return (req, _res, next) => {
    if (!req.nguoiDung) throw loi.chuaDangNhap();
    if (!vaiTroDuocPhep.includes(req.nguoiDung.vaiTro)) throw loi.khongDuQuyen();
    next();
  };
}
