package com.app.homeserve.ui.auth;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.app.homeserve.R;
import com.app.homeserve.common.DieuHuong;
import com.app.homeserve.data.TokenStore;

// Màn mở đầu: xem máy đã đăng nhập chưa rồi chuyển đi ngay.
//   Chưa có token        → Login
//   Có token + QUAN_TRI  → AdminMainActivity
//   Có token + THO       → ThoMainActivity
//   Có token + vai trò lạ (vd KHACH) → xóa token, về Login
// Token hết hạn thì không cần kiểm tra ở đây: lần gọi API đầu tiên server trả 401,
// ApiClient tự xóa token và đưa về Login.
public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        TokenStore tokenStore = TokenStore.get(this);
        if (!tokenStore.daDangNhap()) {
            DieuHuong.moDangNhap(this);
            return;
        }
        if (!DieuHuong.moManChinh(this, tokenStore.layVaiTro())) {
            tokenStore.xoa();
            DieuHuong.moDangNhap(this);
        }
    }
}
