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
JOIN danh_muc_dv dm ON dm.ten = v.danh_muc
ORDER BY dm.id, v.ten;
  
  -- Mục 8: dữ liệu mẫu cho cơ sở dữ liệu demo mới.
BEGIN;

DO $$
DECLARE
  khu_vuc_mau_id integer;
  khach_mau_id integer;
  tho_mau_ids integer[] := ARRAY[]::integer[];
  dich_vu_mau_ids integer[] := ARRAY[]::integer[];
  tho_mau_id integer;
  yeu_cau_mau_id integer;
  dich_vu_mau record;
  vi_tri_tho integer;
  trang_thai_don text;
  tao_luc_mau timestamptz;
  lich_hen_mau timestamptz;
  diem_khach integer;
BEGIN
  SELECT id INTO khu_vuc_mau_id
  FROM khu_vuc
  ORDER BY id
  LIMIT 1;

  IF khu_vuc_mau_id IS NULL THEN
    RAISE EXCEPTION 'Cần có ít nhất một khu vực trước khi tạo dữ liệu Mục 8';
  END IF;

  -- Tài khoản mẫu phục vụ hiển thị dữ liệu, không dùng để đăng nhập.
  INSERT INTO nguoi_dung (email, mat_khau_hash, ho_ten, vai_tro)
  VALUES ('seed8-khach@example.invalid', 'SEED_NO_LOGIN', 'Khách mẫu', 'KHACH')
  RETURNING id INTO khach_mau_id;

  -- Mỗi thợ được gắn với một dịch vụ thuộc đúng nghề của mình.
  FOR i IN 1..25 LOOP
    SELECT id, danh_muc_id INTO dich_vu_mau
    FROM dich_vu
    ORDER BY id
    OFFSET (i - 1)
    LIMIT 1;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Cần ít nhất 25 dịch vụ trước khi tạo dữ liệu Mục 8';
    END IF;

    INSERT INTO nguoi_dung (email, mat_khau_hash, ho_ten, vai_tro)
    VALUES (
      format('seed8-tho-%s@example.invalid', i),
      'SEED_NO_LOGIN',
      format('Thợ mẫu %s', i),
      'THO'
    )
    RETURNING id INTO tho_mau_id;

    INSERT INTO ho_so_tho (
      nguoi_dung_id, nghe_id, kinh_nghiem_nam, khu_vuc_id, trang_thai_duyet
    )
    VALUES (
      tho_mau_id, dich_vu_mau.danh_muc_id, 1 + i % 10,
      khu_vuc_mau_id, 'DA_DUYET'
    );

    tho_mau_ids := array_append(tho_mau_ids, tho_mau_id);
    dich_vu_mau_ids := array_append(dich_vu_mau_ids, dich_vu_mau.id);
  END LOOP;

  FOR i IN 1..120 LOOP
    vi_tri_tho := 1 + (i - 1) % 25;
    tho_mau_id := tho_mau_ids[vi_tri_tho];
    tao_luc_mau := now() - (121 - i) * interval '1 day';
    lich_hen_mau := tao_luc_mau + interval '1 day';

    trang_thai_don := CASE
      WHEN i <= 20 THEN 'CHO_NHAN'
      WHEN i <= 40 THEN 'DA_NHAN'
      WHEN i <= 60 THEN 'DANG_LAM'
      WHEN i <= 100 THEN 'HOAN_TAT'
      ELSE 'HUY'
    END;

    INSERT INTO yeu_cau (
      khach_id, dich_vu_id, khu_vuc_id, mo_ta, dia_chi,
      thoi_gian_mong_muon, trang_thai, tao_luc
    )
    VALUES (
      khach_mau_id, dich_vu_mau_ids[vi_tri_tho], khu_vuc_mau_id,
      format('Yêu cầu sửa chữa mẫu %s', i),
      format('Địa chỉ minh họa %s', i),
      lich_hen_mau, trang_thai_don, tao_luc_mau
    )
    RETURNING id INTO yeu_cau_mau_id;

    IF trang_thai_don IN ('DA_NHAN', 'DANG_LAM', 'HOAN_TAT') THEN
      INSERT INTO phan_cong (
        yeu_cau_id, tho_id, trang_thai,
        thoi_gian_du_kien_toi, phan_cong_luc, nhan_luc
      )
      VALUES (
        yeu_cau_mau_id, tho_mau_id, 'DA_NHAN',
        lich_hen_mau, tao_luc_mau + interval '1 hour',
        tao_luc_mau + interval '2 hours'
      );
    END IF;

    -- 40 đơn hoàn tất, mỗi đơn có hai đánh giá.
    IF trang_thai_don = 'HOAN_TAT' THEN
      diem_khach := 3 + i % 3;

      INSERT INTO danh_gia (
        yeu_cau_id, nguoi_danh_gia_id, nguoi_duoc_danh_gia_id,
        so_sao, noi_dung, tao_luc
      )
      VALUES
        (yeu_cau_mau_id, khach_mau_id, tho_mau_id,
         diem_khach, 'Khách đánh giá công việc của thợ', lich_hen_mau),
        (yeu_cau_mau_id, tho_mau_id, khach_mau_id,
         4 + i % 2, 'Thợ đánh giá khách hàng', lich_hen_mau);
    END IF;
  END LOOP;

  UPDATE ho_so_tho hs
  SET so_viec = thong_ke.so_viec,
      diem_tb = thong_ke.diem_tb
  FROM (
    SELECT nguoi_duoc_danh_gia_id,
           count(*)::integer AS so_viec,
           round(avg(so_sao), 1) AS diem_tb
    FROM danh_gia
    WHERE nguoi_danh_gia_id = khach_mau_id
      AND nguoi_duoc_danh_gia_id = ANY(tho_mau_ids)
    GROUP BY nguoi_duoc_danh_gia_id
  ) AS thong_ke
  WHERE hs.nguoi_dung_id = thong_ke.nguoi_duoc_danh_gia_id;
END $$;

COMMIT;