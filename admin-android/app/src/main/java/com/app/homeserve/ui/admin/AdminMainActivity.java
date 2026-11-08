package com.app.homeserve.ui.admin;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.app.homeserve.R;
import com.app.homeserve.ui.admin.baocao.BaoCaoFragment;
import com.app.homeserve.ui.admin.danhmuc.DanhMucFragment;
import com.app.homeserve.ui.admin.phanviec.BanPhanViecFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;

// Màn hình chính của Quản trị: chỉ là cái vỏ chứa thanh tab.
// Bấm tab nào thì gắn Fragment của tab đó vào khung_noi_dung.
public class AdminMainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_main);

        BottomNavigationView thanhTab = findViewById(R.id.thanh_tab);
        thanhTab.setOnItemSelectedListener(item -> {
            moTab(item.getItemId());
            return true;   // true = cho phép tab được chọn (tô đậm)
        });

        // Chỉ chọn tab mặc định khi mở lần đầu. Khi xoay màn hình,
        // Android tự giữ lại tab và Fragment đang mở, không cần làm lại.
        if (savedInstanceState == null) {
            thanhTab.setSelectedItemId(R.id.tab_phan_viec);
        }
    }

    // Dùng if/else chứ không dùng switch: từ AGP 8, R.id không còn là hằng số
    // nên switch (R.id...) báo lỗi biên dịch.
    private void moTab(int idTab) {
        Fragment f;
        if (idTab == R.id.tab_danh_muc) f = new DanhMucFragment();
        else if (idTab == R.id.tab_duyet) f = new DuyetFragment();
        else if (idTab == R.id.tab_bao_cao) f = new BaoCaoFragment();
        else f = new BanPhanViecFragment();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.khung_noi_dung, f)
                .commit();
    }
}
