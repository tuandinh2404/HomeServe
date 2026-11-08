package com.app.homeserve.ui.admin;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.app.homeserve.R;
import com.app.homeserve.ui.admin.baogia.BaoGiaVuotTranFragment;
import com.app.homeserve.ui.admin.hosotho.HoSoThoFragment;
import com.app.homeserve.ui.admin.khieunai.KhieuNaiFragment;
import com.google.android.material.tabs.TabLayout;

// Tab "Duyệt" của Quản trị: 3 tab con Hồ sơ thợ · Báo giá · Khiếu nại.
// Thanh tab dưới đáy chỉ chứa tối đa 5 mục, nên 3 việc duyệt gom chung vào đây.
public class DuyetFragment extends Fragment {

    public DuyetFragment() {
        super(R.layout.fragment_admin_duyet);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        TabLayout tabCon = view.findViewById(R.id.tab_duyet_con);
        tabCon.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override public void onTabSelected(TabLayout.Tab tab) { moTabCon(tab.getPosition()); }
            @Override public void onTabUnselected(TabLayout.Tab tab) { }
            @Override public void onTabReselected(TabLayout.Tab tab) { }
        });
        // Hiện tab con đang được chọn (lần đầu là vị trí 0 = Hồ sơ thợ)
        moTabCon(tabCon.getSelectedTabPosition());
    }

    // Vị trí 0, 1, 2 theo đúng thứ tự TabItem trong fragment_admin_duyet.xml
    private void moTabCon(int viTri) {
        Fragment f;
        if (viTri == 1) f = new BaoGiaVuotTranFragment();
        else if (viTri == 2) f = new KhieuNaiFragment();
        else f = new HoSoThoFragment();
        // Fragment nằm BÊN TRONG fragment khác thì dùng getChildFragmentManager()
        getChildFragmentManager().beginTransaction()
                .replace(R.id.khung_duyet, f)
                .commit();
    }
}
