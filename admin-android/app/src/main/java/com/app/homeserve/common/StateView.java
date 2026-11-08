package com.app.homeserve.common;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.app.homeserve.R;

// Khung 3 trạng thái dùng chung cho mọi màn hình có gọi API: đang tải / có dữ liệu / lỗi.
//
// Cách dùng: trong layout, BỌC nội dung (thường là RecyclerView) bằng StateView:
//   <com.app.homeserve.common.StateView
//       android:id="@+id/state_view"
//       android:layout_width="match_parent"
//       android:layout_height="match_parent">
//       <androidx.recyclerview.widget.RecyclerView ... />
//   </com.app.homeserve.common.StateView>
//
// Trong code:
//   stateView = view.findViewById(R.id.state_view);
//   stateView.setOnThuLai(this::taiDuLieu);    // bấm "Thử lại" thì gọi lại API
//   stateView.showLoading();                    // trước khi gọi API
//   stateView.showContent();                    // API trả về có dữ liệu
//   stateView.showEmpty("Chưa có yêu cầu nào"); // API trả về danh sách rỗng
//   stateView.showError(LoiApiHelper.thongBao(res));  // API lỗi / mất mạng
public class StateView extends FrameLayout {

    private final View lopPhu;
    private final ProgressBar pbDangTai;
    private final TextView tvThongBao;
    private final Button btnThuLai;
    @Nullable private Runnable thuLai;

    public StateView(@NonNull Context context) {
        this(context, null);
    }

    public StateView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        lopPhu = LayoutInflater.from(context).inflate(R.layout.view_state, this, false);
        pbDangTai = lopPhu.findViewById(R.id.pb_dang_tai);
        tvThongBao = lopPhu.findViewById(R.id.tv_thong_bao);
        btnThuLai = lopPhu.findViewById(R.id.btn_thu_lai);
        btnThuLai.setOnClickListener(v -> {
            if (thuLai != null) thuLai.run();
        });
        lopPhu.setVisibility(GONE);
    }

    // Gọi sau khi Android đã gắn xong các view con viết trong XML.
    // Thêm lớp phủ vào SAU CÙNG để nó nằm đè lên trên nội dung.
    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        addView(lopPhu);
    }

    public void setOnThuLai(@Nullable Runnable thuLai) {
        this.thuLai = thuLai;
    }

    public void showLoading() {
        hienLopPhu(true, null, false);
    }

    public void showContent() {
        lopPhu.setVisibility(GONE);
        datNoiDung(VISIBLE);
    }

    public void showEmpty(String thongBao) {
        hienLopPhu(false, thongBao, false);
    }

    public void showError(String thongBao) {
        hienLopPhu(false, thongBao, thuLai != null);   // chỉ hiện nút khi đã gắn setOnThuLai
    }

    private void hienLopPhu(boolean dangTai, @Nullable String thongBao, boolean coNutThuLai) {
        datNoiDung(GONE);
        pbDangTai.setVisibility(dangTai ? VISIBLE : GONE);
        tvThongBao.setText(thongBao);
        tvThongBao.setVisibility(thongBao == null ? GONE : VISIBLE);
        btnThuLai.setVisibility(coNutThuLai ? VISIBLE : GONE);
        lopPhu.setVisibility(VISIBLE);
    }

    // Ẩn / hiện mọi view con trừ lớp phủ
    private void datNoiDung(int visibility) {
        for (int i = 0; i < getChildCount(); i++) {
            View con = getChildAt(i);
            if (con != lopPhu) con.setVisibility(visibility);
        }
    }
}
