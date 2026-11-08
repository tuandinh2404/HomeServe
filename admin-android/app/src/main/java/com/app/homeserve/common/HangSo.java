package com.app.homeserve.common;

// Các giá trị cố định, viết Y HỆT backend/api.md (mục "Giá trị cố định").
// Backend, app Android và app Flutter phải dùng đúng các chuỗi này.
// Cách dùng:  if (HangSo.VaiTro.QUAN_TRI.equals(vaiTro)) ...
// Muốn hiện cho người dùng đọc thì dùng HangSo.tenHienThi(ma).
public final class HangSo {

    private HangSo() { }   // chỉ chứa hằng số, không tạo đối tượng

    // nguoi_dung.vai_tro
    public static final class VaiTro {
        public static final String KHACH = "KHACH";
        public static final String THO = "THO";
        public static final String QUAN_TRI = "QUAN_TRI";
    }

    // ho_so_tho.trang_thai_duyet
    public static final class TrangThaiDuyet {
        public static final String CHO_DUYET = "CHO_DUYET";
        public static final String DA_DUYET = "DA_DUYET";
        public static final String TU_CHOI = "TU_CHOI";
    }

    // yeu_cau.trang_thai — chỉ đi theo thứ tự CHO_NHAN → DA_NHAN → DANG_LAM → HOAN_TAT
    public static final class TrangThaiYeuCau {
        public static final String CHO_NHAN = "CHO_NHAN";
        public static final String DA_NHAN = "DA_NHAN";
        public static final String DANG_LAM = "DANG_LAM";
        public static final String HOAN_TAT = "HOAN_TAT";
        public static final String HUY = "HUY";
    }

    // phan_cong.trang_thai
    public static final class TrangThaiPhanCong {
        public static final String CHO_THO_NHAN = "CHO_THO_NHAN";
        public static final String DA_NHAN = "DA_NHAN";
        public static final String TU_CHOI = "TU_CHOI";
    }

    // khieu_nai.trang_thai
    public static final class TrangThaiKhieuNai {
        public static final String MOI = "MOI";
        public static final String DANG_XU_LY = "DANG_XU_LY";
        public static final String DA_XU_LY = "DA_XU_LY";
    }

    // Đổi mã sang chữ tiếng Việt để hiện lên màn hình (chip trạng thái, ...).
    // Server thêm mã mới mà ở đây chưa có thì trả nguyên mã, để dễ nhận ra còn thiếu.
    public static String tenHienThi(String ma) {
        if (ma == null) return "";
        switch (ma) {
            case "KHACH": return "Khách hàng";
            case "THO": return "Thợ";
            case "QUAN_TRI": return "Quản trị";
            case "CHO_DUYET": return "Chờ duyệt";
            case "DA_DUYET": return "Đã duyệt";
            case "TU_CHOI": return "Từ chối";
            case "CHO_NHAN": return "Chờ nhận";
            case "DA_NHAN": return "Đã nhận";
            case "DANG_LAM": return "Đang làm";
            case "HOAN_TAT": return "Hoàn tất";
            case "HUY": return "Đã hủy";
            case "CHO_THO_NHAN": return "Chờ thợ nhận";
            case "MOI": return "Mới";
            case "DANG_XU_LY": return "Đang xử lý";
            case "DA_XU_LY": return "Đã xử lý";
            default: return ma;
        }
    }
}
