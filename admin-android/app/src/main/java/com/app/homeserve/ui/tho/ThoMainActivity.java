package com.app.homeserve.ui.tho;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.app.homeserve.R;
import com.app.homeserve.ui.tho.hoso.HoSoFragment;
import com.app.homeserve.ui.tho.viec.ViecCuaToiFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;

// Màn hình chính của Thợ: 2 tab Việc của tôi · Hồ sơ. Cách làm giống AdminMainActivity.
public class ThoMainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tho_main);

        BottomNavigationView thanhTab = findViewById(R.id.thanh_tab);
        thanhTab.setOnItemSelectedListener(item -> {
            moTab(item.getItemId());
            return true;
        });

        if (savedInstanceState == null) {
            thanhTab.setSelectedItemId(R.id.tab_viec);
        }
    }

    private void moTab(int idTab) {
        Fragment f = (idTab == R.id.tab_ho_so) ? new HoSoFragment() : new ViecCuaToiFragment();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.khung_noi_dung, f)
                .commit();
    }
}
