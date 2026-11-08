import type { ErrorRequestHandler, RequestHandler } from "express";

// Lỗi có chủ đích để trả về cho app, theo mẫu api.md:  { "loi": "...", "truong": "..." }
// Trong route chỉ cần:  throw loi.saiDuLieu("Email không đúng định dạng", "email");
// Express 5 tự chuyển lỗi (kể cả trong hàm async) xuống xuLyLoi ở cuối app.ts.
export class LoiApi extends Error {
  readonly ma: number;
  readonly truong: string | undefined;

  constructor(ma: number, thongBao: string, truong?: string) {
    super(thongBao);
    this.ma = ma;
    this.truong = truong;
  }
}

// Các lỗi hay dùng, tên theo nghĩa để đọc code dễ hiểu
export const loi = {
  saiDuLieu: (thongBao: string, truong?: string) => new LoiApi(400, thongBao, truong),
  chuaDangNhap: (thongBao = "Bạn chưa đăng nhập hoặc phiên đã hết hạn") => new LoiApi(401, thongBao),
  khongDuQuyen: (thongBao = "Bạn không có quyền làm việc này") => new LoiApi(403, thongBao),
  khongTimThay: (thongBao = "Không tìm thấy dữ liệu") => new LoiApi(404, thongBao),
  xungDot: (thongBao: string, truong?: string) => new LoiApi(409, thongBao, truong),
};

// Gọi tới đường dẫn không tồn tại → 404 đúng mẫu thay vì trang HTML mặc định của Express
export const khongCoDuongDan: RequestHandler = (req, res) => {
  res.status(404).json({ loi: `Không có đường dẫn ${req.method} ${req.path}` });
};

// Nơi DUY NHẤT trả lỗi về cho app. Phải gắn CUỐI CÙNG trong app.ts.
export const xuLyLoi: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof LoiApi) {
    res.status(err.ma).json(err.truong ? { loi: err.message, truong: err.truong } : { loi: err.message });
    return;
  }
  // App gửi body không phải JSON hợp lệ
  if (err?.type === "entity.parse.failed") {
    res.status(400).json({ loi: "Dữ liệu gửi lên không phải JSON hợp lệ" });
    return;
  }
  // Lỗi ràng buộc từ PostgreSQL: đổi sang mã HTTP đúng nghĩa thay vì 500
  switch (err?.code) {
    case "23505": // UNIQUE
      res.status(409).json({ loi: "Dữ liệu bị trùng với bản ghi đã có" });
      return;
    case "23503": // FOREIGN KEY
      res.status(409).json({ loi: "Dữ liệu đang được dùng ở nơi khác, hoặc tham chiếu tới thứ không tồn tại" });
      return;
    case "23514": // CHECK
    case "23502": // NOT NULL
    case "22P02": // sai kiểu, vd chữ vào cột số
      res.status(400).json({ loi: "Dữ liệu gửi lên chưa đúng" });
      return;
  }
  console.error(err); // lỗi không lường trước: in ra log Render để dò, không gửi chi tiết cho app
  res.status(500).json({ loi: "Lỗi máy chủ, thử lại sau" });
};
