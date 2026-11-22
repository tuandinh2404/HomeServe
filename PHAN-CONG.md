# Phân công hiện tại – HomeServe

Cập nhật: **22/11/2026** (cuối tuần 11). Nhóm **CTRL C CTRL V** · Đề 14.

Tài liệu này ghi **mỗi người đang ở đâu và làm gì tiếp**. Làm xong việc nào thì báo nhóm trưởng để cập nhật.

---

## 1. Tình hình chung

| Phần | Đã có | Còn thiếu |
|---|---|---|
| **Backend** | Đăng nhập / đăng ký, danh mục + dịch vụ (xem, thêm, sửa, xóa), hồ sơ thợ + duyệt, yêu cầu (tạo, của tôi, chi tiết, hủy), tải ảnh, **phân công + tìm thợ phù hợp ②**, **báo giá + đánh dấu vượt trần ①**, thanh toán (transaction), dữ liệu mẫu đủ đề | `GET /yeu-cau` cho bàn phân việc · đánh giá · khiếu nại · báo cáo · công nợ · thợ tự đăng ký |
| **Server thật** | https://homeserve-vm96.onrender.com | ⚠️ Đang chạy **bản cũ**, chưa có API mới của Tâm. Nhóm trưởng deploy lại (mục 2) |
| **CSDL Supabase** | 13 bảng, RLS | ⚠️ **Chưa nạp dữ liệu mẫu mới** (120 yêu cầu, 27 thợ, 80 đánh giá). Nhóm trưởng nạp lại (mục 2) |
| **App Android** | Khung đầy đủ, **đăng nhập chạy thật**, bàn phân việc (dữ liệu giả) | **Màn danh mục** (màn thứ 2 của mốc tuần 11) và các màn nghiệp vụ |
| **App Flutter** | Toàn bộ giao diện, **đăng nhập + danh mục chạy thật** | Nối các màn yêu cầu, thanh toán, đánh giá, khiếu nại với API thật |

### Số commit (đề yêu cầu mỗi người ≥ 15 commit có ý nghĩa, rải đều)

| Đình Tuấn | Duy Tuấn | Thông | Tâm |
|---|---|---|---|
| 54 ✅ | 7 | 5 | 5 |

Ba bạn còn thiếu **8–10 commit** trong 4 tuần còn lại. Chia nhỏ: mỗi màn hình, mỗi API, mỗi lần sửa lỗi là **một commit riêng**.

---

## 2. Làm NGAY (tuần này)

| Người | Việc | Vì sao gấp |
|---|---|---|
| **Đình Tuấn** | Render → **Manual Deploy → Deploy latest commit**; Settings → **Auto-Deploy = On Commit** | Server đang chạy bản cũ, mọi API mới đều 404 |
| **Đình Tuấn** | Supabase → chạy lại `schema.sql` → `seed.sql` → `seed-tai-khoan.sql` (nhánh `backend`, thư mục `backend/sql/`) | Có dữ liệu thật để 2 app làm màn hình |
| **Thông** | **Màn danh mục + dịch vụ** (README Android, mục 5.1): xem danh sách bằng API thật, thêm / sửa / xóa có hỏi lại | Màn thứ 2 của **mốc tuần 11** cho app Android. API đã có đủ |
| **Tâm** | Thêm **`GET /yeu-cau?trangThai=&khuVuc=&trang=&soLuong=`** (chỉ `QUAN_TRI`) | Bàn phân việc của Thông cần API này |
| **Duy Tuấn** | Sau khi server deploy xong: đặt `mockYeuCau = false`, nối **tạo yêu cầu** (kèm tải ảnh `/tai-len`) và **yêu cầu của tôi** | API của Tâm đã có |

---

## 3. Việc từng người (tuần 12–13)

### Nguyễn Đình Tuấn (nhóm trưởng)
- [ ] Deploy + nạp lại CSDL (mục 2)
- [ ] API **thợ tự đăng ký** (tài khoản `THO` + hồ sơ chờ duyệt)
- [ ] API **đánh giá hai chiều** (cập nhật `diem_tb` của thợ trong transaction)
- [ ] API **khiếu nại** + ghi quyết định
- [ ] API **3 báo cáo** (dịch vụ phổ biến, thời gian phản hồi, thợ bị khiếu nại) + **công nợ** + ghi nộp hoa hồng
- [ ] Android: **màn báo cáo có biểu đồ** + công nợ thợ
- [ ] **Đổi tên gói / tên app / TAG log theo mã nhóm** cho cả 2 app (đề mục E.4), làm sớm
- [ ] Xem PR của cả nhóm trước khi merge

### Huỳnh Minh Tâm (backend)
- [ ] `GET /yeu-cau` cho bàn phân việc (mục 2)
- [ ] `seed.sql`: thêm **báo giá** (có vài dòng **vượt giá trần, chưa xem xét** để demo điểm nhấn ①) và **thanh toán** cho các yêu cầu Hoàn tất; thêm khách hàng (hiện chỉ 2); sửa để dịch vụ id 1 là "Thay ổ cắm"
- [ ] Ghi chi tiết các API đã viết vào **`backend/api.md`** (dữ liệu gửi lên, trả về, mã lỗi) để Thông và Duy Tuấn khỏi phải đoán
- [ ] Sửa lỗi API theo phản hồi của 2 app
- [ ] **Đọc lại và tự giải thích được** `phanCong.ts` (tìm thợ phù hợp) và `baoGia.ts` (vượt trần). Khi bảo vệ, thầy sẽ hỏi đúng phần này

### Nguyễn Hoàng Thông (Android)
Chi tiết từng màn có trong `admin-android/README.md` mục 5.
- [ ] 5.1 Danh mục + dịch vụ (mục 2)
- [ ] 5.3 **Duyệt hồ sơ thợ** (`GET /ho-so-tho`, `PATCH /ho-so-tho/:id/duyet`)
- [ ] 5.5 **Bàn phân việc bằng API thật + tìm thợ phù hợp ②** (chờ `GET /yeu-cau` của Tâm)
- [ ] 5.7 **Báo giá vượt trần ①** (`GET /bao-gia-chi-tiet?vuotTran=true&daXemXet=false`)
- [ ] Màn của Thợ: 5.2 hồ sơ, 5.4 việc của tôi (nhận / từ chối, bắt đầu làm), 5.6 gửi báo giá
- [ ] 5.8 Khiếu nại (chờ API của nhóm trưởng)

### Nguyễn Duy Tuấn (Flutter)
- [ ] Tạo yêu cầu: mô tả, ảnh (`/tai-len`), địa chỉ (bản đồ hoặc nhập tay), khu vực, giờ mong muốn
- [ ] Yêu cầu của tôi + chi tiết: thợ được giao (tên, ảnh, số sao, số việc), giờ dự kiến tới, **báo giá từng hạng mục**
- [ ] Hủy yêu cầu kèm **SnackBar Hoàn tác**
- [ ] Xác nhận hoàn tất + **thanh toán**
- [ ] Đánh giá thợ, gửi khiếu nại (chờ API của nhóm trưởng)
- [ ] Xử lý lỗi mạng mọi màn; `flutter analyze` sạch

---

## 4. Tuần 14–15: hoàn thiện (cả nhóm)

- [ ] Kiểm tra phân quyền bằng Postman: tài khoản sai vai trò gọi API phải ra **403**
- [ ] Bảng **≥ 25 trường hợp kiểm thử** có kết quả thật (yêu cầu của báo cáo)
- [ ] File **APK release** của cả 2 app, cài được trên máy thật
- [ ] **Video demo 5–8 phút**: luồng chính khách đặt → quản trị phân công → thợ báo giá (vượt trần) → quản trị xem xét → khách thanh toán, đánh giá
- [ ] **Báo cáo 20–35 trang** (dùng lại use case, ERD từ bản nộp tuần 9)
- [ ] Bảng phân công có **chữ ký** cả nhóm

---

## 5. Quy tắc làm việc

1. **Nhánh và PR:** làm trên nhánh riêng (`backend-…`, `android-…`, `flutter-…`), mở PR vào đúng nhánh chính (`backend`, `admin-android`, `client-flutter`). **Chờ nhóm trưởng xem rồi mới merge**, chọn *Create a merge commit*, không Squash.
2. **Sửa đúng file có sẵn trong khung** (ví dụ `ui/admin/danhmuc/`, `routes/yeuCau.ts`). Không tạo file trùng tên ở chỗ khác.
3. **Commit nhỏ, rải đều, viết rõ đã làm gì.** Không dồn cả trăm dòng vào một commit lúc nửa đêm.
4. **Hiểu code mình commit.** Đề cho dùng AI nhưng *"phải hiểu và giải thích được từng dòng"*. Không giải thích được thì coi như không phải của mình.
5. **Không đưa mật khẩu, khóa bí mật** (`.env`) vào commit hay nhóm chat.
6. Kẹt quá nửa buổi thì hỏi ngay trong nhóm.

### Tài khoản thử (mật khẩu `123456`)
`quantri@homeserve.vn` · `tho.dien@homeserve.vn` · `tho.choduyet@homeserve.vn` · `khach@homeserve.vn`

### Tài liệu
- Backend: [`backend/README.md`](https://github.com/tuandinh2404/HomeServe/blob/backend/backend/README.md) · [`backend/api.md`](https://github.com/tuandinh2404/HomeServe/blob/backend/backend/api.md)
- Android: [`admin-android/README.md`](https://github.com/tuandinh2404/HomeServe/blob/admin-android/admin-android/README.md)
- Flutter: [`client-flutter/README.md`](https://github.com/tuandinh2404/HomeServe/blob/client-flutter/client-flutter/README.md)
- Phân tích (use case, ERD): [README trang chính](README.md)
