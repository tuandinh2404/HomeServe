package com.app.homeserve.common;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

// Định dạng tiền VND để HIỂN THỊ. Gửi lên API vẫn dùng số nguyên long (150000).
//   TienTe.hien(150000)              → "150.000 đ"
//   TienTe.khoang(80000, 150000)     → "80.000 – 150.000 đ"   (giá sàn – giá trần)
//   TienTe.doc("150.000")            → 150000                  (đọc lại từ ô nhập, null nếu sai)
public final class TienTe {

    // Ký hiệu tiền đặt sau số. Muốn đổi thành "₫" hay "VND" thì sửa ở đây.
    private static final String KY_HIEU = " đ";

    // Tự đặt dấu "." ngăn hàng nghìn, không phụ thuộc ngôn ngữ của điện thoại
    // (máy để tiếng Anh vẫn hiện 150.000 chứ không thành 150,000).
    private static final DecimalFormat DINH_DANG;
    static {
        DecimalFormatSymbols kyHieu = new DecimalFormatSymbols();
        kyHieu.setGroupingSeparator('.');
        DINH_DANG = new DecimalFormat("#,##0", kyHieu);
    }

    private TienTe() { }

    public static String so(long soTien) {
        synchronized (DINH_DANG) {          // DecimalFormat không an toàn khi nhiều luồng dùng chung
            return DINH_DANG.format(soTien);
        }
    }

    public static String hien(long soTien) {
        return so(soTien) + KY_HIEU;
    }

    public static String khoang(long giaSan, long giaTran) {
        return so(giaSan) + " – " + so(giaTran) + KY_HIEU;
    }

    // Đọc số tiền người dùng gõ: bỏ dấu chấm, dấu phẩy, khoảng trắng, chữ "đ".
    // Trả null nếu rỗng, không phải số, hoặc quá lớn → form tự báo lỗi ô đó.
    public static Long doc(String chuoi) {
        if (chuoi == null) return null;
        String chiSo = chuoi.replaceAll("[.,\\s]", "").replace("đ", "").replace("₫", "");
        if (chiSo.isEmpty() || !chiSo.matches("\\d{1,12}")) return null;
        return Long.parseLong(chiSo);
    }
}
