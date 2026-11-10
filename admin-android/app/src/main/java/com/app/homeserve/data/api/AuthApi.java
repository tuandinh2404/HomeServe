package com.app.homeserve.data.api;

import com.app.homeserve.data.model.KetQuaDangNhap;
import com.app.homeserve.data.model.YeuCauDangNhap;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

// Các API đăng nhập (mục 2 của api.md). Đường dẫn KHÔNG có "/" ở đầu,
// vì BASE_URL đã kết thúc bằng "/".
public interface AuthApi {

    @POST("auth/dang-nhap")
    Call<KetQuaDangNhap> dangNhap(@Body YeuCauDangNhap body);
}
