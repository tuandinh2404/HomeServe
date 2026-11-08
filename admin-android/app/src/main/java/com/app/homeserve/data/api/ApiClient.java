package com.app.homeserve.data.api;

import android.content.Context;
import android.content.Intent;

import com.app.homeserve.BuildConfig;
import com.app.homeserve.data.TokenStore;
import com.app.homeserve.ui.auth.LoginActivity;

import java.util.concurrent.TimeUnit;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

// Nơi DUY NHẤT tạo Retrofit cho cả app.
// Cách dùng:  ApiClient.get(this).create(DanhMucApi.class).layDanhMuc().enqueue(...)
// (trong Fragment thay "this" bằng requireContext())
public class ApiClient {

    // Server Render miễn phí ngủ sau 15 phút, lần gọi đầu mất 30–50 giây mới dậy.
    // Để 60 giây cho khỏi báo lỗi mạng oan. Muốn chờ lâu hơn thì tăng số này.
    private static final int THOI_GIAN_CHO_GIAY = 60;

    private static Retrofit retrofit;

    public static synchronized Retrofit get(Context context) {
        if (retrofit == null) {
            Context app = context.getApplicationContext();
            TokenStore tokenStore = TokenStore.get(app);

            // ① Gắn token vào MỌI request, để màn hình không phải tự thêm header
            Interceptor ganToken = chain -> {
                Request.Builder builder = chain.request().newBuilder();
                String token = tokenStore.layToken();
                if (token != null) builder.header("Authorization", "Bearer " + token);
                return chain.proceed(builder.build());
            };

            // ② Server trả 401 = token hỏng / hết hạn → xóa token, đưa về màn đăng nhập.
            //    Chỉ làm khi ĐANG đăng nhập: lúc đăng nhập sai mật khẩu server cũng trả 401,
            //    khi đó chưa có token nên bỏ qua, để màn Login tự báo "sai mật khẩu".
            Interceptor xuLy401 = chain -> {
                Response response = chain.proceed(chain.request());
                if (response.code() == 401 && tokenStore.daDangNhap()) {
                    tokenStore.xoa();
                    Intent intent = new Intent(app, LoginActivity.class);
                    // NEW_TASK: bắt buộc khi mở Activity từ application context
                    // CLEAR_TASK: xóa các màn cũ, bấm Back không quay lại được
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    app.startActivity(intent);
                }
                return response;
            };

            // ③ In request/response ra Logcat (lọc chữ "okhttp") để dò lỗi.
            //    Chỉ bật khi chạy từ Android Studio (bản debug), bản phát hành thì tắt.
            HttpLoggingInterceptor log = new HttpLoggingInterceptor();
            log.setLevel(BuildConfig.DEBUG
                    ? HttpLoggingInterceptor.Level.BODY
                    : HttpLoggingInterceptor.Level.NONE);

            OkHttpClient client = new OkHttpClient.Builder()
                    .addInterceptor(ganToken)
                    .addInterceptor(xuLy401)
                    .addInterceptor(log)
                    .connectTimeout(THOI_GIAN_CHO_GIAY, TimeUnit.SECONDS)
                    .readTimeout(THOI_GIAN_CHO_GIAY, TimeUnit.SECONDS)
                    .build();

            retrofit = new Retrofit.Builder()
                    .baseUrl(BuildConfig.BASE_URL)                     // lấy từ build.gradle.kts
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create()) // JSON ↔ object Java
                    .build();
        }
        return retrofit;
    }
}
