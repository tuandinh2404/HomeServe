package com.app.homeserve.api;

import com.app.homeserve.models.KetQuaDangNhap;
import com.app.homeserve.models.YeuCauDangNhap;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface ApiService {
    @POST("auth/dang-nhap")
    Call<KetQuaDangNhap> dangNhap(@Body YeuCauDangNhap body);
}