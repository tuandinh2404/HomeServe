package com.app.homeserve.data;

import android.content.Context;
import android.content.SharedPreferences;

// Lưu token đăng nhập, vai trò và họ tên vào bộ nhớ máy (SharedPreferences),
// để tắt app mở lại vẫn còn đăng nhập.
// Cách dùng ở bất kỳ màn hình nào:  TokenStore.get(this).layVaiTro()
public class TokenStore {

    // Tên file lưu trên máy và tên các khóa. Đổi tên file = mọi người bị đăng xuất.
    private static final String TEN_FILE = "homeserve_dang_nhap";
    private static final String KHOA_TOKEN = "token";
    private static final String KHOA_VAI_TRO = "vai_tro";
    private static final String KHOA_HO_TEN = "ho_ten";

    // Cả app chỉ dùng chung 1 TokenStore (singleton)
    private static TokenStore instance;
    private final SharedPreferences prefs;

    private TokenStore(Context context) {
        // getApplicationContext(): không giữ Activity lại trong bộ nhớ sau khi nó đóng
        prefs = context.getApplicationContext()
                .getSharedPreferences(TEN_FILE, Context.MODE_PRIVATE);
    }

    public static synchronized TokenStore get(Context context) {
        if (instance == null) instance = new TokenStore(context);
        return instance;
    }

    // Gọi sau khi đăng nhập thành công
    public void luu(String token, String vaiTro, String hoTen) {
        prefs.edit()
                .putString(KHOA_TOKEN, token)
                .putString(KHOA_VAI_TRO, vaiTro)
                .putString(KHOA_HO_TEN, hoTen)
                .apply();   // apply(): ghi nền, không làm đứng giao diện
    }

    public String layToken() { return prefs.getString(KHOA_TOKEN, null); }
    public String layVaiTro() { return prefs.getString(KHOA_VAI_TRO, null); }
    public String layHoTen() { return prefs.getString(KHOA_HO_TEN, null); }

    public boolean daDangNhap() { return layToken() != null; }

    // Gọi khi đăng xuất hoặc khi server báo token hết hạn (401)
    public void xoa() { prefs.edit().clear().apply(); }
}
