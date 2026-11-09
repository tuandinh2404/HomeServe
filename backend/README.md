# HomeServe – Backend

REST API dùng chung cho **app Admin (Android)** và **app Khách hàng (Flutter)**. Cả 2 app gọi vào đây, đọc ghi cùng **một** CSDL PostgreSQL trên Supabase.

| | |
|---|---|
| Ngôn ngữ | TypeScript (Node 20+, đề cho phép: *"Không bắt buộc TypeScript"*) |
| Khung | Express 5 |
| CSDL | PostgreSQL trên Supabase, truy cập bằng thư viện `pg`, **viết SQL tay** |
| Xác thực | JWT + bcrypt |
| Chạy ở | Render (Web Service gói Free, Singapore) |
| **Link API** | **https://homeserve-vm96.onrender.com** (thử: `/health`, `/danh-muc-dv`) |
| Tài liệu API | `api.md` trong thư mục này. **Đây là nguồn chuẩn**: đường dẫn, tên trường, mã lỗi đều theo file này |

### Ai làm gì

| Người | Phần |
|---|---|
| **Tuấn** | Khung (`app.ts`, `db.ts`, `loi.ts`, middleware), deploy Render, đăng ký / đăng nhập, đánh giá, khiếu nại, báo cáo, công nợ |
| **Tâm** | Hoàn thiện `seed.sql`, danh mục + dịch vụ (thêm / sửa / xóa), hồ sơ thợ, yêu cầu, phân công + thợ phù hợp (**điểm nhấn ②**), báo giá vượt trần (**điểm nhấn ①**), thanh toán, tải ảnh |

---

## 0. Tâm bắt đầu từ đây

Tuấn đã làm sẵn phần đầu để Tâm có mẫu nhìn theo:
- `sql/schema.sql`: đủ 13 bảng, chạy lại được ✅
- `sql/seed.sql`: 17 khu vực, 6 danh mục, 42 dịch vụ có bảng giá ✅
- `routes/danhMuc.ts`, `routes/dichVu.ts`: 3 API xem danh mục, dịch vụ, bảng giá ✅

**Thứ tự đọc và làm:**
1. Đọc mục 1, chạy được server trên máy, mở `http://localhost:3000/danh-muc-dv` thấy 6 danh mục.
2. Mở `sql/schema.sql`, đọc chú thích từng bảng. Đây là "bản đồ" cho mọi API sau này.
3. Mở `routes/dichVu.ts`: đây là **mẫu chuẩn** (đọc tham số, kiểm tra, `pool.query` với `$1`, `throw loi...`, trả JSON). Viết API mới thì copy cách làm ở đây.
4. Việc đầu tiên của Tâm: **thêm / sửa / xóa danh mục và dịch vụ** (chỉ `QUAN_TRI`, dùng `canDangNhap, chiCho("QUAN_TRI")` như mẫu ở mục 3). Đường dẫn và mã lỗi xem bảng *"Quản lý danh mục và dịch vụ"* trong `api.md`.
5. Song song: bổ sung `seed.sql` cho đủ yêu cầu đề (xem mục 4).

Không hiểu chỗ nào trong code mẫu thì hỏi Tuấn **trước khi** viết tiếp.

---

## 1. Chạy trên máy

```
cd backend
npm install
```
Nếu mở thẳng thư mục `backend` bằng VS Code thì terminal đã đứng sẵn trong đó, không cần gõ `cd backend`, chỉ cần `npm install`.
Tạo file `.env` bằng cách copy `.env.example`, rồi **xin Tuấn các giá trị** (nhắn riêng, không gửi vào nhóm chung).

```
npm run dev
```
Mở trình duyệt vào `http://localhost:3000/health`:
- `{"ok":true,"csdl":"ok"}` → server và CSDL đều chạy.
- `{"ok":false,...}` (mã 503) → server chạy nhưng không kết nối được CSDL. Xem mục 7.

`npm run dev` tự khởi động lại mỗi khi lưu file.

### Bản đang chạy trên Internet

**https://homeserve-vm96.onrender.com**. Đây là link 2 app gọi tới và link nộp cho thầy.
- **Tự deploy:** mỗi khi có PR merge vào nhánh `backend`, Render tự build và chạy bản mới sau 2–4 phút. Không cần làm gì thêm.
- Build trên Render lỗi thì bản cũ vẫn chạy. Tuấn xem log trong trang Render.
- Biến môi trường trên Render do Tuấn quản lý. Cần thêm biến mới thì nhắn Tuấn.
- Máy cá nhân (`localhost`) và Render **dùng chung một CSDL Supabase**. Thử xóa / sửa dữ liệu trên máy là mất trên bản thật luôn, cẩn thận.

⚠️ **Không bao giờ commit file `.env`.** Nó có mật khẩu CSDL và khóa toàn quyền của Supabase. `.gitignore` đã chặn sẵn. Lỡ commit rồi thì báo Tuấn **đổi mật khẩu ngay**: xóa file thôi chưa đủ, vì Git vẫn giữ lịch sử.

---

## 2. Cấu trúc thư mục

```
backend/
├── src/
│   ├── index.ts           [Tuấn] Mở cổng, chạy server. Ít khi phải sửa
│   ├── app.ts             [Tuấn] Tạo app Express, gắn middleware, routes, xử lý lỗi
│   ├── db.ts              [Tuấn] pool kết nối CSDL + hàm giaoDich() cho transaction   ✅
│   ├── loi.ts             [Tuấn] LoiApi, loi.saiDuLieu(...), xử lý lỗi chung           ✅
│   ├── middleware/
│   │   └── xacThuc.ts     [Tuấn] canDangNhap, chiCho("QUAN_TRI"), taoToken              ✅
│   └── routes/
│       ├── index.ts       [Tuấn] Gom mọi router. Thêm file router mới thì đăng ký ở đây
│       ├── health.ts      [Tuấn] GET /health (hỏi thử CSDL)                              ✅
│       ├── auth.ts        [Tuấn] /auth/dang-ky, /auth/dang-nhap, /auth/toi              ✅
│       ├── danhMuc.ts     [TÂM]  /danh-muc-dv                       (GET ✅, thêm/sửa/xóa: Tâm)
│       ├── dichVu.ts      [TÂM]  /dich-vu, /dich-vu/:id/bang-gia    (GET ✅, thêm/sửa/xóa: Tâm)
│       ├── hoSoTho.ts     [TÂM]  /tho/ho-so, /ho-so-tho
│       ├── yeuCau.ts      [TÂM]  /yeu-cau, /yeu-cau/:id/tho-phu-hop, ...
│       ├── phanCong.ts    [TÂM]  /yeu-cau/:id/phan-cong, /tho/toi/viec, /phan-cong/:id/nhan
│       ├── baoGia.ts      [TÂM]  /bao-gia-chi-tiet
│       ├── thanhToan.ts   [TÂM]  /thanh-toan
│       ├── taiLen.ts      [TÂM]  /tai-len
│       ├── danhGia.ts     [Tuấn] /danh-gia
│       ├── khieuNai.ts    [Tuấn] /khieu-nai
│       └── baoCao.ts      [Tuấn] /bao-cao/*, /tho/:id/cong-no
├── sql/
│   ├── schema.sql         13 bảng, chạy lại được từ đầu (DROP rồi CREATE)                ✅
│   ├── seed.sql           [TÂM]  Dữ liệu mẫu. Đã có khu vực, danh mục, dịch vụ; Tâm bổ sung phần còn lại
│   └── seed-tai-khoan.sql [Tuấn] Tài khoản thử mỗi vai trò, chạy lại được không xóa gì       ✅
├── api.md                 Tài liệu API (nguồn chuẩn)
├── .env.example           Danh sách biến môi trường (không có giá trị thật)
└── README.md
```

Mỗi file router đã có sẵn và **đã được đăng ký** trong `routes/index.ts`. Mở file của mình ra viết là chạy được ngay.

### Quy tắc file
- **Chỉ sửa file router của mình.** Cần sửa `app.ts`, `db.ts`, `loi.ts`, `routes/index.ts`, `package.json` thì nhắn Tuấn.
- **Dùng `import`, không dùng `require`.** Project là ES module (`"type": "module"` trong `package.json`). Viết `const { Router } = require("express")` thì `npx tsc` **vẫn qua** nhưng server **sập ngay khi chạy** (`require is not defined in ES module scope`). Đúng: `import { Router } from "express";`
- **Import phải có đuôi `.js`**, kể cả khi file thật là `.ts`: `import { pool } from "../db.js";`. Đây là quy định của TypeScript khi chạy kiểu module (`"module": "nodenext"`). Thiếu `.js` thì `npm run build` báo lỗi.
- Đường dẫn đầy đủ viết **ngay trong file router**, ví dụ `danhMucRouter.get("/danh-muc-dv", ...)`, để tìm trong code là ra đúng chuỗi như `api.md`.

---

## 3. Viết một API: mẫu

```ts
import { Router } from "express";

import { pool } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const danhMucRouter = Router();

// GET /danh-muc-dv — công khai
danhMucRouter.get("/danh-muc-dv", async (_req, res) => {
  const { rows } = await pool.query(
    `SELECT dm.id, dm.ten, COUNT(dv.id)::int AS so_dich_vu
       FROM danh_muc_dv dm
       LEFT JOIN dich_vu dv ON dv.danh_muc_id = dm.id
      GROUP BY dm.id
      ORDER BY dm.ten`,
  );
  res.json(rows);
});

// POST /danh-muc-dv — chỉ QUAN_TRI
danhMucRouter.post("/danh-muc-dv", canDangNhap, chiCho("QUAN_TRI"), async (req, res) => {
  const ten = String(req.body?.ten ?? "").trim();
  if (!ten) throw loi.saiDuLieu("Nhập tên danh mục", "ten");

  const { rows } = await pool.query(
    "INSERT INTO danh_muc_dv (ten) VALUES ($1) RETURNING id, ten",
    [ten],
  );
  res.status(201).json(rows[0]);
  // Trùng tên → PostgreSQL báo lỗi UNIQUE → loi.ts tự trả 409, không cần tự bắt
});
```

**Những điều bắt buộc** (thầy chấm đúng các mục này):

| Quy tắc | Đúng | Sai |
|---|---|---|
| Tham số SQL dùng `$1, $2` | `pool.query("... WHERE id = $1", [id])` | `` pool.query(`... WHERE id = ${id}`) `` ← lỗ hổng SQL injection |
| Lỗi trả theo mẫu `{ "loi", "truong" }` | `throw loi.saiDuLieu("Giá trần phải ≥ giá sàn", "gia_tran")` | `res.status(400).send("sai")` |
| Mã HTTP đúng nghĩa | 201 khi tạo mới, 404 khi không có, 409 khi xung đột | Lỗi gì cũng 500 |
| **Phân quyền ở server** | `chiCho("QUAN_TRI")` trên route | Chỉ ẩn nút trên app (thầy thử bằng Postman với tài khoản sai vai trò) |
| **Mọi quyết định nghiệp vụ ở server** | Server tự tính `vuot_tran`, `thanh_tien`, hoa hồng | Tin số app gửi lên |
| Không trả mật khẩu | `SELECT id, email, ho_ten ...` | `SELECT * FROM nguoi_dung` |
| Tên trường JSON là `snake_case` | `gia_tran`, `danh_muc_id` (trả thẳng `rows` của `pg`) | Tự đổi sang `giaTran` |

### Lỗi: không cần `try/catch`

Express 5 tự bắt lỗi trong hàm `async` và chuyển xuống `loi.ts`. Chỉ cần `throw`:

| Muốn trả | Viết |
|---|---|
| 400 dữ liệu sai | `throw loi.saiDuLieu("Thông báo", "ten_truong")` |
| 401 chưa đăng nhập | `throw loi.chuaDangNhap()` (thường middleware lo) |
| 403 sai vai trò / không phải của mình | `throw loi.khongDuQuyen()` |
| 404 không có | `throw loi.khongTimThay("Không tìm thấy yêu cầu")` |
| 409 xung đột | `throw loi.xungDot("Danh mục còn dịch vụ, không xóa được")` |

`loi.ts` cũng tự đổi lỗi PostgreSQL: trùng `UNIQUE` → **409**, vướng khóa ngoại → **409**, sai `CHECK` / `NOT NULL` / sai kiểu → **400**.

### Transaction: dùng `giaoDich()`

Khi 2–3 câu SQL phải **cùng thành công hoặc cùng hủy** (đề bắt buộc ≥ 1 chỗ: thanh toán, phân công...):
```ts
import { giaoDich } from "../db.js";

const ketQua = await giaoDich(async (client) => {
  await client.query("INSERT INTO thanh_toan (yeu_cau_id, tong_tien, ...) VALUES ($1, $2, ...)", [id, tong]);
  await client.query("UPDATE yeu_cau SET trang_thai = 'HOAN_TAT' WHERE id = $1", [id]);
  return { id };
});
```
Trong `giaoDich` phải dùng **`client.query`**, **không** dùng `pool.query`. `pool.query` chạy trên kết nối khác, nằm ngoài transaction.

---

## 4. CSDL

- `sql/schema.sql`: tạo toàn bộ bảng, **chạy lại từ đầu được** (đầu file `DROP TABLE IF EXISTS ... CASCADE`).
- `sql/seed.sql`: dữ liệu mẫu. Đề 14 yêu cầu tối thiểu:

  | Dữ liệu | Đề yêu cầu | Đã có |
  |---|---|---|
  | Danh mục | 6 | ✅ 6 |
  | Dịch vụ có bảng giá | 40 | ✅ 42 |
  | Khu vực | (không yêu cầu) | ✅ 17 |
  | Thợ | 25 | ⏳ 2 (trong `seed-tai-khoan.sql`). Tâm thêm cho đủ 25 |
  | Yêu cầu đủ 5 trạng thái | 120 | ⏳ |
  | Đánh giá | 80 | ⏳ |

  120 yêu cầu thì đừng gõ tay từng dòng: dùng `generate_series` + `random()` trong SQL để sinh hàng loạt. Thợ mẫu dùng chung mật khẩu băm như trong `seed-tai-khoan.sql` (mật khẩu `123456`).
- `sql/seed-tai-khoan.sql`: tài khoản thử, **chạy lại nhiều lần được**, không xóa dữ liệu khác.
- Chạy: Supabase → **SQL Editor** → dán nội dung file → **Run**. Thứ tự: `schema.sql` → `seed.sql` → `seed-tai-khoan.sql`. Chạy lại `schema.sql` là **xóa sạch**, phải chạy lại cả 2 file seed.

### Tài khoản thử (mật khẩu đều là `123456`)

| Vai trò | Email | Ghi chú |
|---|---|---|
| Quản trị | `quantri@homeserve.vn` | App Android |
| Thợ đã duyệt | `tho.dien@homeserve.vn` | App Android. Nghề Điện, Quận 1, 4.8 sao |
| Thợ chờ duyệt | `tho.choduyet@homeserve.vn` | App Android. Nghề Nước, Quận 3, để thử màn duyệt hồ sơ |
| Khách hàng | `khach@homeserve.vn` | App Flutter (app Android sẽ chặn) |

### Gọi API cần đăng nhập (thử bằng Postman)

1. `POST /auth/dang-nhap` với body JSON `{"email":"quantri@homeserve.vn","mat_khau":"123456"}` → copy `token`.
2. Ở request khác: tab **Authorization** → Type **Bearer Token** → dán token.
3. Thử phân quyền đúng như thầy sẽ thử: đăng nhập bằng `khach@...` rồi gọi API chỉ dành cho quản trị → phải ra **403**.
- Tiền là `INTEGER` (VND). Thời gian là `TIMESTAMPTZ`. Mật khẩu chỉ lưu dạng băm bcrypt (`mat_khau_hash`).

Thiết kế bảng chi tiết: xem bản thiết kế CSDL nhóm đã chốt.

---

## 5. Git

Nhánh chính của backend là **`backend`**. Không push thẳng vào đó, luôn đi qua Pull Request.

```
git checkout backend
git pull
git checkout -b backend-danh-muc          # tên nhánh: backend-<tính năng>
# ... code, commit nhiều lần ...
git push -u origin backend-danh-muc
```
GitHub → **Pull request** → **base: `backend`** → báo Tuấn xem → merge bằng **Create a merge commit** (không chọn Squash).

**Trước khi mở PR:**
```
npm run build
```
Phải chạy xong **không báo lỗi**. Render cũng chạy đúng lệnh này khi deploy, lỗi ở máy thì lên Render cũng lỗi.

**Commit:** mỗi người ≥ 15 commit có ý nghĩa, rải đều các tuần, bằng tài khoản GitHub của mình (`git config user.email` = email GitHub). Mỗi commit một việc: ✅ `Them API tao bao gia, so sanh gia tran` · ❌ `update`.

---

## 6. Lịch backend

| Tuần | Tuấn | Tâm |
|---|---|---|
| 9 | Khung (`db`, `loi`, routes) ✅, `schema.sql` ✅, seed danh mục / dịch vụ ✅, 3 API xem ✅ | Đọc README + code mẫu, chạy được trên máy |
| 10 | Deploy Render ✅, đăng ký / đăng nhập ✅ | Sửa thứ tự id + bật RLS trong `sql/`, thêm / sửa / xóa danh mục + dịch vụ (đã có `chiCho` để dùng), bổ sung `seed.sql` |
| **11** | **Mốc kiểm tra:** backend đã deploy, 3 API thật (đăng nhập, danh mục, dịch vụ / bảng giá) | |
| 12–13 | Đánh giá, khiếu nại, báo cáo, công nợ | Hồ sơ thợ, yêu cầu, phân công + thợ phù hợp, báo giá vượt trần, thanh toán, tải ảnh |
| 14–15 | Dữ liệu mẫu đủ số lượng, sửa lỗi, kiểm tra phân quyền bằng Postman | |

---

## 7. Khi bị kẹt

| Vấn đề | Làm gì |
|---|---|
| `/health` trả `"csdl":"không kết nối được"` | Supabase gói Free **tự tạm dừng sau 7 ngày** không dùng. Vào supabase.com → project → **Resume project**. Vẫn lỗi thì hỏi Tuấn chuỗi `DATABASE_URL` mới |
| `npm run build` báo `Cannot find module '../db'` | Thiếu đuôi `.js` trong import |
| API trả 500 | Xem dòng lỗi in ra ở cửa sổ `npm run dev`. Thường là sai tên cột / tên bảng |
| Không biết API trả gì | Xem `api.md`. Chưa có trong đó thì hỏi Tuấn trước khi tự đặt |
