-- =====================================================================
-- HomeServe — seed-tai-khoan.sql
-- Tài khoản thử, mỗi vai trò ít nhất 1 (đề yêu cầu ghi trong README).
-- Chạy SAU schema.sql và seed.sql. Chạy lại nhiều lần cũng được (trùng thì bỏ qua),
-- KHÔNG xóa dữ liệu khác.
--
-- Mật khẩu mọi tài khoản: 123456
-- (mat_khau_hash bên dưới là bcrypt của "123456", tạo bằng bcryptjs, 10 vòng)
-- =====================================================================

INSERT INTO nguoi_dung (email, mat_khau_hash, ho_ten, sdt, vai_tro) VALUES
  ('quantri@homeserve.vn',      '$2b$10$HiV4Yg86n.Jfx8e68TNr0O.gO9FfefgvtdXA.TQ8r20lVvBbCMsjG', 'Quản trị HomeServe', '0900000001', 'QUAN_TRI'),
  ('tho.dien@homeserve.vn',     '$2b$10$HiV4Yg86n.Jfx8e68TNr0O.gO9FfefgvtdXA.TQ8r20lVvBbCMsjG', 'Trần Văn Điện',      '0900000002', 'THO'),
  ('tho.choduyet@homeserve.vn', '$2b$10$HiV4Yg86n.Jfx8e68TNr0O.gO9FfefgvtdXA.TQ8r20lVvBbCMsjG', 'Lê Văn Nước',        '0900000003', 'THO'),
  ('khach@homeserve.vn',        '$2b$10$HiV4Yg86n.Jfx8e68TNr0O.gO9FfefgvtdXA.TQ8r20lVvBbCMsjG', 'Nguyễn Thị Khách',   '0900000004', 'KHACH')
ON CONFLICT (email) DO NOTHING;

-- Hồ sơ cho 2 thợ: 1 đã duyệt (nhận việc được), 1 đang chờ duyệt (để thử màn duyệt hồ sơ)
INSERT INTO ho_so_tho (nguoi_dung_id, nghe_id, kinh_nghiem_nam, khu_vuc_id, trang_thai_duyet, diem_tb, so_viec)
SELECT nd.id, dm.id, v.kinh_nghiem, kv.id, v.trang_thai, v.diem_tb, v.so_viec
FROM (VALUES
  ('tho.dien@homeserve.vn',     'Điện', 5, 'Quận 1', 'DA_DUYET',  4.8, 32),
  ('tho.choduyet@homeserve.vn', 'Nước', 2, 'Quận 3', 'CHO_DUYET', 0.0, 0)
) AS v (email, nghe, kinh_nghiem, khu_vuc, trang_thai, diem_tb, so_viec)
JOIN nguoi_dung nd  ON nd.email = v.email
JOIN danh_muc_dv dm ON dm.ten = v.nghe
JOIN khu_vuc kv     ON kv.ten = v.khu_vuc
ON CONFLICT (nguoi_dung_id) DO NOTHING;
