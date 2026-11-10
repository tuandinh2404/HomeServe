package com.app.homeserve.data.model;

import com.google.gson.annotations.SerializedName;

// Người dùng server trả về (trong kết quả đăng nhập, /auth/toi, ...)
public class NguoiDung {
    @SerializedName("id") public int id;
    @SerializedName("email") public String email;
    @SerializedName("ho_ten") public String hoTen;
    @SerializedName("sdt") public String sdt;
    @SerializedName("vai_tro") public String vaiTro;   // KHACH / THO / QUAN_TRI
}
