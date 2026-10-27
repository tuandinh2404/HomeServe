# HomeServe – Ứng dụng khách hàng (Flutter)

Ứng dụng di động cho khách hàng đặt dịch vụ sửa chữa tại nhà, kết nối với backend HomeServe.

## Tính năng chính
- Đăng ký / đăng nhập, lưu token.
- Xem danh mục và danh sách dịch vụ, chi tiết giá sàn – giá trần.
- Tạo yêu cầu dịch vụ (mô tả, địa chỉ, khu vực, thời gian mong muốn, ảnh).
- Theo dõi danh sách và chi tiết yêu cầu, trạng thái tiến trình.
- Hủy yêu cầu, thanh toán, đánh giá thợ, gửi khiếu nại.
- Hồ sơ cá nhân.

## Chạy ứng dụng
```bash
flutter pub get
flutter run
```

Mặc định ứng dụng dùng dữ liệu mẫu (mock) để giao diện chạy được ngay cả khi backend chưa sẵn sàng.
Để gọi backend thật, đặt `ApiService.useMock = false` và cập nhật `AppConstants.apiBaseUrl`.
