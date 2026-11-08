package com.app.homeserve.api;

import android.content.Context;
import java.util.concurrent.TimeUnit;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class ApiClient {
    // URL tạm, sau này thay bằng link web service trên Render. Nhớ giữ nguyên dấu / ở cuối.
    private static final String BASE_URL = "https://ten-app.onrender.com/";
    private static Retrofit retrofit;

    public static ApiService get(Context ctx) {
        if (retrofit == null) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY); // In log console để dễ gỡ lỗi

            OkHttpClient client = new OkHttpClient.Builder()
                    .addInterceptor(chain -> {
                        String token = TokenStore.layToken(ctx);
                        Request.Builder builder = chain.request().newBuilder();
                        if (token != null) {
                            builder.addHeader("Authorization", "Bearer " + token);
                        }
                        return chain.proceed(builder.build());
                    })
                    .addInterceptor(logging)
                    .connectTimeout(90, TimeUnit.SECONDS) // Bắt buộc để 90s vì Render gói Free thức dậy chậm
                    .readTimeout(90, TimeUnit.SECONDS)
                    .build();

            retrofit = new Retrofit.Builder()
                    .baseUrl(BASE_URL)
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
        }
        return retrofit.create(ApiService.class);
    }
}