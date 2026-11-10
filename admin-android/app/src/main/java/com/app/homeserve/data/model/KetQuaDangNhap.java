package com.app.homeserve.data.model;

import com.google.gson.annotations.SerializedName;

// Server trả về khi đăng nhập đúng: { "token": "...", "nguoi_dung": { ... } }
public class KetQuaDangNhap {
    @SerializedName("token") public String token;
    @SerializedName("nguoi_dung") public NguoiDung nguoiDung;
}
