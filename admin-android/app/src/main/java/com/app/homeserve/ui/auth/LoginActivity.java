package com.app.homeserve.ui.auth;

import android.os.Bundle;
import android.util.Patterns;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.app.homeserve.R;
import com.app.homeserve.common.DieuHuong;
import com.app.homeserve.common.HangSo;
import com.app.homeserve.common.LoiApiHelper;
import com.app.homeserve.data.TokenStore;
import com.app.homeserve.data.api.ApiClient;
import com.app.homeserve.data.api.AuthApi;
import com.app.homeserve.data.model.KetQuaDangNhap;
import com.app.homeserve.data.model.NguoiDung;
import com.app.homeserve.data.model.YeuCauDangNhap;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.progressindicator.CircularProgressIndicator;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

// Màn đăng nhập cho Quản trị và Thợ (layout Material của Thông: activity_login.xml).
// Khách hàng dùng app Flutter nên bị chặn ở đây.
public class LoginActivity extends AppCompatActivity {

    private TextInputLayout tilEmail, tilPassword;
    private TextInputEditText etEmail, etPassword;
    private MaterialButton btnLogin;
    private CircularProgressIndicator progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        tilEmail = findViewById(R.id.tilEmail);
        tilPassword = findViewById(R.id.tilPassword);
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        btnLogin = findViewById(R.id.btnLogin);
        progressBar = findViewById(R.id.progressBar);

        btnLogin.setOnClickListener(v -> xuLyDangNhap());
    }

    private void xuLyDangNhap() {
        String email = etEmail.getText() == null ? "" : etEmail.getText().toString().trim();
        String matKhau = etPassword.getText() == null ? "" : etPassword.getText().toString();
        tilEmail.setError(null);
        tilPassword.setError(null);

        // 1. Kiểm tra trên app trước, sai thì báo ngay dưới ô và không gọi API
        if (email.isEmpty()) { tilEmail.setError(getString(R.string.error_email_required)); return; }
        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) { tilEmail.setError(getString(R.string.error_email_invalid)); return; }
        if (matKhau.isEmpty()) { tilPassword.setError(getString(R.string.error_password_required)); return; }

        dangGui(true);
        ApiClient.get(this).create(AuthApi.class)
                .dangNhap(new YeuCauDangNhap(email, matKhau))
                .enqueue(new Callback<KetQuaDangNhap>() {
                    @Override
                    public void onResponse(@NonNull Call<KetQuaDangNhap> call, @NonNull Response<KetQuaDangNhap> res) {
                        dangGui(false);
                        if (!res.isSuccessful() || res.body() == null || res.body().nguoiDung == null) {
                            baoLoiServer(res);
                            return;
                        }
                        dangNhapThanhCong(res.body());
                    }

                    @Override
                    public void onFailure(@NonNull Call<KetQuaDangNhap> call, @NonNull Throwable t) {
                        dangGui(false);
                        Toast.makeText(LoginActivity.this, LoiApiHelper.LOI_MANG, Toast.LENGTH_LONG).show();
                    }
                });
    }

    private void dangNhapThanhCong(KetQuaDangNhap kq) {
        NguoiDung nd = kq.nguoiDung;
        // 2. Khách hàng không dùng app này: không lưu gì, chỉ báo
        if (HangSo.VaiTro.KHACH.equals(nd.vaiTro)) {
            Toast.makeText(this, "Tài khoản này dùng app khách hàng", Toast.LENGTH_LONG).show();
            return;
        }
        // 3. Lưu token + vai trò (TokenStore của khung), rồi mở đúng màn theo vai trò
        TokenStore.get(this).luu(kq.token, nd.vaiTro, nd.hoTen);
        if (!DieuHuong.moManChinh(this, nd.vaiTro)) {
            TokenStore.get(this).xoa();   // vai trò lạ: không cho vào
            Toast.makeText(this, R.string.role_not_supported, Toast.LENGTH_LONG).show();
        }
    }

    // Server báo lỗi: có "truong" thì báo dưới ô đó, không thì hiện câu thông báo
    private void baoLoiServer(Response<?> res) {
        LoiApiHelper.Loi loi = LoiApiHelper.doc(res);
        if ("email".equals(loi.truong)) tilEmail.setError(loi.thongBao);
        else if ("mat_khau".equals(loi.truong)) tilPassword.setError(loi.thongBao);
        else Toast.makeText(this, loi.thongBao, Toast.LENGTH_LONG).show();
    }

    // Đang gửi: vòng xoay hiện ngay trong nút, khóa nút để không bấm 2 lần
    private void dangGui(boolean dangGui) {
        progressBar.setVisibility(dangGui ? View.VISIBLE : View.GONE);
        btnLogin.setEnabled(!dangGui);
        btnLogin.setText(dangGui ? "" : getString(R.string.btn_login));
    }
}
