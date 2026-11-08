-- =====================================================================
-- HomeServe — seed.sql
-- Dữ liệu mẫu. Chạy SAU schema.sql (schema.sql đã xóa sạch bảng nên chạy lại được).
--
-- Đề 14 yêu cầu tối thiểu:
--   6 danh mục ✅ · 40 dịch vụ có bảng giá ✅ (42) · 25 thợ ⏳ · 120 yêu cầu đủ trạng thái ⏳ · 80 đánh giá ⏳
-- Phần ⏳ cần tài khoản (mật khẩu băm bcrypt) → thêm sau khi có API đăng ký / đăng nhập.
-- Giá: tham khảo mặt bằng giá thợ ở TP.HCM, đơn vị VND, đã gồm công.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Khu vực nhận việc
-- ---------------------------------------------------------------------
INSERT INTO khu_vuc (ten) VALUES
  ('Quận 1'), ('Quận 3'), ('Quận 4'), ('Quận 5'), ('Quận 6'), ('Quận 7'), ('Quận 8'),
  ('Quận 10'), ('Quận 11'), ('Quận 12'), ('Bình Thạnh'), ('Gò Vấp'), ('Phú Nhuận'),
  ('Tân Bình'), ('Tân Phú'), ('Bình Tân'), ('Thủ Đức');

-- ---------------------------------------------------------------------
-- 6 danh mục
-- ---------------------------------------------------------------------
INSERT INTO danh_muc_dv (ten) VALUES
  ('Điện'), ('Nước'), ('Máy lạnh'), ('Máy giặt - Tủ lạnh'), ('Sơn - Chống thấm'), ('Khóa - Cửa');

-- ---------------------------------------------------------------------
-- 42 dịch vụ + bảng giá tham chiếu (giá sàn – giá trần)
-- Lấy id danh mục theo tên để không phụ thuộc thứ tự id.
-- ---------------------------------------------------------------------
INSERT INTO dich_vu (danh_muc_id, ten, mo_ta, don_vi, gia_san, gia_tran)
SELECT dm.id, v.ten, v.mo_ta, v.don_vi, v.gia_san, v.gia_tran
FROM (VALUES
  -- Điện
  ('Điện', 'Thay ổ cắm', 'Tháo ổ cũ, lắp ổ mới, kiểm tra điện', 'cái', 80000, 150000),
  ('Điện', 'Thay công tắc', 'Tháo công tắc cũ, lắp mới', 'cái', 70000, 130000),
  ('Điện', 'Lắp đèn trần', 'Lắp đèn LED âm trần hoặc ốp trần', 'bộ', 100000, 200000),
  ('Điện', 'Thay aptomat (CB)', 'Thay CB tổng hoặc CB nhánh', 'cái', 150000, 300000),
  ('Điện', 'Sửa chập điện', 'Dò tìm và khắc phục chỗ chập', 'lần', 200000, 500000),
  ('Điện', 'Đi lại dây điện nổi', 'Đi dây trong ống nẹp', 'mét', 30000, 60000),
  ('Điện', 'Lắp quạt trần', 'Lắp quạt trần kèm hộp số', 'bộ', 200000, 400000),
  -- Nước
  ('Nước', 'Thông tắc bồn cầu', 'Thông tắc bằng dụng cụ chuyên dụng', 'lần', 250000, 500000),
  ('Nước', 'Thông tắc cống, lavabo', 'Thông tắc đường thoát nước', 'lần', 200000, 450000),
  ('Nước', 'Thay vòi lavabo', 'Tháo vòi cũ, lắp vòi mới', 'cái', 100000, 200000),
  ('Nước', 'Sửa rò rỉ ống nước', 'Tìm và xử lý chỗ rò rỉ', 'lần', 150000, 400000),
  ('Nước', 'Lắp máy nước nóng', 'Lắp máy nước nóng trực tiếp hoặc gián tiếp', 'bộ', 300000, 600000),
  ('Nước', 'Thay phao bồn nước', 'Thay phao cơ hoặc phao điện', 'cái', 150000, 300000),
  ('Nước', 'Sửa máy bơm nước', 'Kiểm tra, thay tụ, thay phớt', 'lần', 200000, 500000),
  -- Máy lạnh
  ('Máy lạnh', 'Vệ sinh máy lạnh treo tường', 'Vệ sinh dàn nóng, dàn lạnh', 'bộ', 150000, 250000),
  ('Máy lạnh', 'Nạp gas R32', 'Nạp bổ sung gas R32', 'lần', 250000, 500000),
  ('Máy lạnh', 'Nạp gas R410A', 'Nạp bổ sung gas R410A', 'lần', 300000, 550000),
  ('Máy lạnh', 'Lắp đặt máy lạnh mới', 'Lắp máy 1–1.5HP, chưa gồm ống đồng', 'bộ', 300000, 500000),
  ('Máy lạnh', 'Tháo máy lạnh', 'Tháo dàn nóng, dàn lạnh, thu hồi gas', 'bộ', 200000, 350000),
  ('Máy lạnh', 'Thay tụ máy lạnh', 'Thay tụ khởi động block', 'cái', 250000, 450000),
  ('Máy lạnh', 'Sửa máy lạnh chảy nước', 'Thông ống thoát, chỉnh độ nghiêng', 'lần', 150000, 300000),
  -- Máy giặt - Tủ lạnh
  ('Máy giặt - Tủ lạnh', 'Vệ sinh máy giặt cửa trên', 'Tháo lồng giặt, vệ sinh', 'cái', 250000, 400000),
  ('Máy giặt - Tủ lạnh', 'Vệ sinh máy giặt cửa ngang', 'Tháo lồng giặt, vệ sinh', 'cái', 350000, 550000),
  ('Máy giặt - Tủ lạnh', 'Sửa máy giặt không vắt', 'Kiểm tra dây curoa, motor, bo mạch', 'lần', 200000, 600000),
  ('Máy giặt - Tủ lạnh', 'Thay van cấp nước máy giặt', 'Thay van điện cấp nước', 'cái', 250000, 450000),
  ('Máy giặt - Tủ lạnh', 'Sửa tủ lạnh không lạnh', 'Kiểm tra gas, block, quạt', 'lần', 250000, 700000),
  ('Máy giặt - Tủ lạnh', 'Nạp gas tủ lạnh', 'Hàn ống, nạp gas', 'lần', 400000, 800000),
  ('Máy giặt - Tủ lạnh', 'Thay ron cửa tủ lạnh', 'Thay gioăng cao su cửa tủ', 'cửa', 250000, 450000),
  -- Sơn - Chống thấm
  ('Sơn - Chống thấm', 'Sơn tường trong nhà', 'Sơn lại 2 lớp, chưa gồm sơn', 'm²', 25000, 45000),
  ('Sơn - Chống thấm', 'Sơn tường ngoài trời', 'Sơn 2 lớp, chưa gồm sơn', 'm²', 35000, 60000),
  ('Sơn - Chống thấm', 'Bả matit tường', 'Bả 2 lớp, xả nhám', 'm²', 20000, 40000),
  ('Sơn - Chống thấm', 'Chống thấm sàn vệ sinh', 'Quét màng chống thấm 2 lớp', 'm²', 120000, 220000),
  ('Sơn - Chống thấm', 'Chống thấm sân thượng', 'Xử lý nứt, quét chống thấm', 'm²', 150000, 280000),
  ('Sơn - Chống thấm', 'Xử lý tường ẩm mốc', 'Cạo lớp hư, xử lý mốc, sơn lại', 'm²', 60000, 120000),
  ('Sơn - Chống thấm', 'Trám vết nứt tường', 'Đục rộng, trám vữa hoặc keo', 'mét', 50000, 100000),
  -- Khóa - Cửa
  ('Khóa - Cửa', 'Mở khóa cửa nhà', 'Mở khóa không phá', 'lần', 150000, 300000),
  ('Khóa - Cửa', 'Thay ổ khóa cửa', 'Tháo ổ cũ, lắp ổ mới, chưa gồm ổ', 'cái', 100000, 200000),
  ('Khóa - Cửa', 'Lắp khóa vân tay', 'Khoan, lắp đặt, cài đặt vân tay', 'bộ', 300000, 600000),
  ('Khóa - Cửa', 'Sửa cửa cuốn kẹt', 'Tra dầu, chỉnh ray, thay lá hỏng', 'lần', 250000, 600000),
  ('Khóa - Cửa', 'Thay bản lề cửa gỗ', 'Thay bản lề, cân chỉnh cánh', 'cái', 80000, 150000),
  ('Khóa - Cửa', 'Sửa cửa nhôm kính trượt', 'Thay bánh xe, chỉnh ray', 'cánh', 150000, 350000),
  ('Khóa - Cửa', 'Lắp tay co thủy lực', 'Lắp tay đóng cửa tự động', 'cái', 150000, 300000)
) AS v (danh_muc, ten, mo_ta, don_vi, gia_san, gia_tran)
JOIN danh_muc_dv dm ON dm.ten = v.danh_muc;
