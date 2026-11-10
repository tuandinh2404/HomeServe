package com.app.homeserve.data.model;

import com.google.gson.annotations.SerializedName;

// Dữ liệu gửi lên POST /auth/dang-nhap. Tên trong ngoặc phải đúng api.md (snake_case).
public class YeuCauDangNhap {
    @SerializedName("email") public String email;
    @SerializedName("mat_khau") public String matKhau;

    public YeuCauDangNhap(String email, String matKhau) {
        this.email = email;
        this.matKhau = matKhau;
    }
}
