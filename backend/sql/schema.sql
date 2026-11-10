-- =====================================================================
-- HomeServe — schema.sql
-- Tạo toàn bộ bảng. CHẠY LẠI ĐƯỢC TỪ ĐẦU: xóa bảng cũ rồi tạo lại.
-- ⚠️ Chạy file này là MẤT HẾT dữ liệu cũ. Chạy xong nhớ chạy seed.sql.
-- Cách chạy: Supabase → SQL Editor → dán toàn bộ file → Run.
--
-- Tên bảng / cột theo gợi ý của đề 14, thêm vài cột để làm được 2 điểm nhấn:
--   ① báo giá vượt trần: bao_gia_chi_tiet.dich_vu_id + vuot_tran + da_xem_xet
--   ② thợ phù hợp: ho_so_tho.nghe_id + khu_vuc_id (khóa ngoại, so khớp chính xác)
-- Tiền: INTEGER (VND). Thời gian: TIMESTAMPTZ.
-- =====================================================================

DROP TABLE IF EXISTS
  cau_hinh, khieu_nai, danh_gia, nop_hoa_hong, thanh_toan, bao_gia_chi_tiet,
  phan_cong, yeu_cau, ho_so_tho, dich_vu, danh_muc_dv, khu_vuc, nguoi_dung
CASCADE;

-- ---------------------------------------------------------------------
-- 1. Người dùng: cả khách, thợ, quản trị chung 1 bảng, phân biệt bằng vai_tro
-- ---------------------------------------------------------------------
CREATE TABLE nguoi_dung (
  id               SERIAL PRIMARY KEY,
  email            VARCHAR(255) NOT NULL UNIQUE,
  mat_khau_hash    VARCHAR(100) NOT NULL,              -- bcrypt, KHÔNG lưu mật khẩu gốc
  ho_ten           VARCHAR(100) NOT NULL,
  sdt              VARCHAR(15),
  vai_tro          VARCHAR(10)  NOT NULL CHECK (vai_tro IN ('KHACH', 'THO', 'QUAN_TRI')),
  anh_dai_dien_url TEXT,
  tao_luc          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 2. Khu vực: bảng riêng để yêu cầu và thợ so khớp chính xác
--    (để chữ tự gõ thì "Q1", "Quận 1", "quận 1" không khớp nhau)
-- ---------------------------------------------------------------------
CREATE TABLE khu_vuc (
  id  SERIAL PRIMARY KEY,
  ten VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- 3. Danh mục dịch vụ (Điện, Nước, Máy lạnh...) và 4. Dịch vụ + bảng giá tham chiếu
-- ---------------------------------------------------------------------
CREATE TABLE danh_muc_dv (
  id  SERIAL PRIMARY KEY,
  ten VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dich_vu (
  id          SERIAL PRIMARY KEY,
  danh_muc_id INTEGER      NOT NULL REFERENCES danh_muc_dv (id) ON DELETE RESTRICT,  -- còn dịch vụ thì không xóa được danh mục
  ten         VARCHAR(150) NOT NULL,
  mo_ta       TEXT,
  don_vi      VARCHAR(20)  NOT NULL,                  -- cái, m², lần, giờ...
  gia_san     INTEGER      NOT NULL CHECK (gia_san > 0),
  gia_tran    INTEGER      NOT NULL,
  CHECK (gia_tran >= gia_san),
  UNIQUE (danh_muc_id, ten)
);

-- ---------------------------------------------------------------------
-- 5. Hồ sơ thợ: 1 tài khoản THO có đúng 1 hồ sơ
-- ---------------------------------------------------------------------
CREATE TABLE ho_so_tho (
  id               SERIAL PRIMARY KEY,
  nguoi_dung_id    INTEGER     NOT NULL UNIQUE REFERENCES nguoi_dung (id) ON DELETE CASCADE,
  nghe_id          INTEGER     NOT NULL REFERENCES danh_muc_dv (id),   -- nghề = 1 danh mục
  kinh_nghiem_nam  SMALLINT    NOT NULL DEFAULT 0 CHECK (kinh_nghiem_nam >= 0),
  chung_chi_url    TEXT,
  giay_to_url      TEXT,                                               -- giấy tờ tùy thân
  khu_vuc_id       INTEGER     NOT NULL REFERENCES khu_vuc (id),
  trang_thai_duyet VARCHAR(10) NOT NULL DEFAULT 'CHO_DUYET'
                   CHECK (trang_thai_duyet IN ('CHO_DUYET', 'DA_DUYET', 'TU_CHOI')),
  ly_do_tu_choi    TEXT,
  diem_tb          NUMERIC(2, 1) NOT NULL DEFAULT 0 CHECK (diem_tb BETWEEN 0 AND 5),
  so_viec          INTEGER     NOT NULL DEFAULT 0 CHECK (so_viec >= 0),
  tao_luc          TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Tìm thợ phù hợp (điểm nhấn ②) lọc theo nghề + khu vực + đã duyệt
CREATE INDEX idx_ho_so_tho_phu_hop ON ho_so_tho (nghe_id, khu_vuc_id, trang_thai_duyet);

-- ---------------------------------------------------------------------
-- 6. Yêu cầu sửa chữa của khách
-- ---------------------------------------------------------------------
CREATE TABLE yeu_cau (
  id                  SERIAL PRIMARY KEY,
  khach_id            INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  dich_vu_id          INTEGER     NOT NULL REFERENCES dich_vu (id),
  khu_vuc_id          INTEGER     NOT NULL REFERENCES khu_vuc (id),
  mo_ta               TEXT        NOT NULL,
  anh_url             TEXT,                                 -- ảnh / video ngắn trên Supabase Storage
  dia_chi             TEXT        NOT NULL,
  vi_do               NUMERIC(9, 6),
  kinh_do             NUMERIC(9, 6),
  thoi_gian_mong_muon TIMESTAMPTZ NOT NULL,
  trang_thai          VARCHAR(10) NOT NULL DEFAULT 'CHO_NHAN'
                      CHECK (trang_thai IN ('CHO_NHAN', 'DA_NHAN', 'DANG_LAM', 'HOAN_TAT', 'HUY')),
  tao_luc             TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_yeu_cau_ban_phan_viec ON yeu_cau (trang_thai, khu_vuc_id);

-- ---------------------------------------------------------------------
-- 7. Phân công: quản trị giao yêu cầu cho thợ, thợ nhận / từ chối
-- ---------------------------------------------------------------------
CREATE TABLE phan_cong (
  id                    SERIAL PRIMARY KEY,
  yeu_cau_id            INTEGER     NOT NULL REFERENCES yeu_cau (id) ON DELETE CASCADE,
  tho_id                INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  trang_thai            VARCHAR(15) NOT NULL DEFAULT 'CHO_THO_NHAN'
                        CHECK (trang_thai IN ('CHO_THO_NHAN', 'DA_NHAN', 'TU_CHOI')),
  thoi_gian_du_kien_toi TIMESTAMPTZ,                         -- thợ điền khi nhận việc
  phan_cong_luc         TIMESTAMPTZ NOT NULL DEFAULT now(),
  nhan_luc              TIMESTAMPTZ                          -- lúc thợ trả lời; dùng cho báo cáo thời gian phản hồi
);
-- Mỗi yêu cầu chỉ có tối đa 1 phân công ĐANG HIỆU LỰC (chờ nhận hoặc đã nhận).
-- Thợ từ chối thì được giao lại cho thợ khác.
CREATE UNIQUE INDEX uq_phan_cong_dang_hieu_luc ON phan_cong (yeu_cau_id)
  WHERE trang_thai IN ('CHO_THO_NHAN', 'DA_NHAN');

-- ---------------------------------------------------------------------
-- 8. Báo giá chi tiết từng hạng mục — điểm nhấn ①
-- ---------------------------------------------------------------------
CREATE TABLE bao_gia_chi_tiet (
  id          SERIAL PRIMARY KEY,
  yeu_cau_id  INTEGER      NOT NULL REFERENCES yeu_cau (id) ON DELETE CASCADE,
  tho_id      INTEGER      NOT NULL REFERENCES nguoi_dung (id),
  dich_vu_id  INTEGER      NOT NULL REFERENCES dich_vu (id),   -- để biết so với gia_tran nào
  hang_muc    VARCHAR(200) NOT NULL,
  so_luong    INTEGER      NOT NULL CHECK (so_luong > 0),
  don_gia     INTEGER      NOT NULL CHECK (don_gia > 0),
  thanh_tien  INTEGER      GENERATED ALWAYS AS (so_luong * don_gia) STORED,  -- CSDL tự tính, không ai sửa tay được
  vuot_tran   BOOLEAN      NOT NULL,                           -- MÁY CHỦ tự tính khi thêm: don_gia > dich_vu.gia_tran
  da_xem_xet  BOOLEAN      NOT NULL DEFAULT false,
  xem_xet_boi INTEGER      REFERENCES nguoi_dung (id),
  xem_xet_luc TIMESTAMPTZ,
  tao_luc     TIMESTAMPTZ  NOT NULL DEFAULT now()
);
-- Danh sách "báo giá vượt trần cần xem lại" của quản trị
CREATE INDEX idx_bao_gia_can_xem_xet ON bao_gia_chi_tiet (tao_luc) WHERE vuot_tran AND NOT da_xem_xet;

-- ---------------------------------------------------------------------
-- 9. Thanh toán (1 lần / yêu cầu) và 10. Thợ nộp hoa hồng → tính công nợ
--    Công nợ thợ = tổng hoa_hong_san các đơn thợ làm − tổng so_tien đã nộp
-- ---------------------------------------------------------------------
CREATE TABLE thanh_toan (
  id             SERIAL PRIMARY KEY,
  yeu_cau_id     INTEGER       NOT NULL UNIQUE REFERENCES yeu_cau (id),
  tong_tien      INTEGER       NOT NULL CHECK (tong_tien >= 0),
  ti_le_hoa_hong NUMERIC(4, 3) NOT NULL CHECK (ti_le_hoa_hong BETWEEN 0 AND 1),  -- chép từ cau_hinh lúc thanh toán
  hoa_hong_san   INTEGER       NOT NULL CHECK (hoa_hong_san >= 0),
  hinh_thuc      VARCHAR(15)   NOT NULL CHECK (hinh_thuc IN ('TIEN_MAT', 'CHUYEN_KHOAN')),
  thoi_diem      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TABLE nop_hoa_hong (
  id       SERIAL PRIMARY KEY,
  tho_id   INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  so_tien  INTEGER     NOT NULL CHECK (so_tien > 0),
  ngay_nop TIMESTAMPTZ NOT NULL DEFAULT now(),
  ghi_chu  TEXT,
  ghi_boi  INTEGER     REFERENCES nguoi_dung (id)             -- quản trị nào ghi nhận
);

-- ---------------------------------------------------------------------
-- 11. Đánh giá hai chiều: khách đánh giá thợ, thợ đánh giá khách
-- ---------------------------------------------------------------------
CREATE TABLE danh_gia (
  id                     SERIAL PRIMARY KEY,
  yeu_cau_id             INTEGER     NOT NULL REFERENCES yeu_cau (id) ON DELETE CASCADE,
  nguoi_danh_gia_id      INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  nguoi_duoc_danh_gia_id INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  so_sao                 SMALLINT    NOT NULL CHECK (so_sao BETWEEN 1 AND 5),
  noi_dung               TEXT,
  tao_luc                TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (yeu_cau_id, nguoi_danh_gia_id),                     -- mỗi bên đánh giá 1 lần / yêu cầu
  CHECK (nguoi_danh_gia_id <> nguoi_duoc_danh_gia_id)
);

-- ---------------------------------------------------------------------
-- 12. Khiếu nại và tranh chấp giá
-- ---------------------------------------------------------------------
CREATE TABLE khieu_nai (
  id         SERIAL PRIMARY KEY,
  yeu_cau_id INTEGER     NOT NULL REFERENCES yeu_cau (id),
  khach_id   INTEGER     NOT NULL REFERENCES nguoi_dung (id),
  loai       VARCHAR(15) NOT NULL CHECK (loai IN ('GIA_VUOT_TRAN', 'CHAT_LUONG', 'THAI_DO', 'KHAC')),
  noi_dung   TEXT        NOT NULL,
  trang_thai VARCHAR(12) NOT NULL DEFAULT 'MOI' CHECK (trang_thai IN ('MOI', 'DANG_XU_LY', 'DA_XU_LY')),
  quyet_dinh TEXT,
  xu_ly_boi  INTEGER     REFERENCES nguoi_dung (id),
  tao_luc    TIMESTAMPTZ NOT NULL DEFAULT now(),
  xu_ly_luc  TIMESTAMPTZ
);

-- ---------------------------------------------------------------------
-- 13. Cấu hình chung (tỉ lệ hoa hồng...). Bảng phụ, không tính vào 12 bảng chính.
-- ---------------------------------------------------------------------
CREATE TABLE cau_hinh (
  khoa    VARCHAR(50) PRIMARY KEY,
  gia_tri TEXT        NOT NULL
);
INSERT INTO cau_hinh (khoa, gia_tri) VALUES ('ti_le_hoa_hong', '0.10');   -- sàn thu 10% mỗi đơn
-- Bật RLS cho toàn bộ bảng ứng dụng.
ALTER TABLE public.nguoi_dung ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.khu_vuc ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.danh_muc_dv ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dich_vu ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ho_so_tho ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.yeu_cau ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phan_cong ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bao_gia_chi_tiet ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thanh_toan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nop_hoa_hong ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.danh_gia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.khieu_nai ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cau_hinh ENABLE ROW LEVEL SECURITY;