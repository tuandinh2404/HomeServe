package com.app.homeserve.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.app.homeserve.R;
import com.app.homeserve.api.ApiClient;
import com.app.homeserve.api.TokenStore;
import com.app.homeserve.models.KetQuaDangNhap;
import com.app.homeserve.models.YeuCauDangNhap;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LoginActivity extends AppCompatActivity {
    private EditText edtEmail, edtPassword;
    private Button btnLogin;
    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        edtEmail = findViewById(R.id.edtEmail);
        edtPassword = findViewById(R.id.edtPassword);
        btnLogin = findViewById(R.id.btnLogin);
        progressBar = findViewById(R.id.progressBar);

        btnLogin.setOnClickListener(v -> xuLyDangNhap());
    }

    private void xuLyDangNhap() {
        String email = edtEmail.getText().toString().trim();
        String pass = edtPassword.getText().toString().trim();

        if (email.isEmpty() || pass.isEmpty()) {
            Toast.makeText(this, "Vui lòng nhập đủ thông tin", Toast.LENGTH_SHORT).show();
            return;
        }

        // Hiện loading (Trạng thái 1)
        progressBar.setVisibility(View.VISIBLE);
        btnLogin.setEnabled(false);

        YeuCauDangNhap yeuCau = new YeuCauDangNhap(email, pass);
        ApiClient.get(this).dangNhap(yeuCau).enqueue(new Callback<KetQuaDangNhap>() {
            @Override
            public void onResponse(Call<KetQuaDangNhap> call, Response<KetQuaDangNhap> response) {
                progressBar.setVisibility(View.GONE);
                btnLogin.setEnabled(true);

                if (response.isSuccessful() && response.body() != null) {
                    // Thành công (Trạng thái 2): Lưu token và chuyển màn hình
                    TokenStore.luuToken(LoginActivity.this, response.body().token);
                    Toast.makeText(LoginActivity.this, "Đăng nhập thành công!", Toast.LENGTH_SHORT).show();

                    startActivity(new Intent(LoginActivity.this, MainActivity.class));
                    finish(); // Đóng màn hình login
                } else {
                    // Sai mật khẩu hoặc lỗi server
                    Toast.makeText(LoginActivity.this, "Đăng nhập thất bại: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<KetQuaDangNhap> call, Throwable t) {
                // Lỗi mạng (Trạng thái 3)
                progressBar.setVisibility(View.GONE);
                btnLogin.setEnabled(true);
                Toast.makeText(LoginActivity.this, "Lỗi kết nối mạng!", Toast.LENGTH_SHORT).show();
            }
        });
    }
}