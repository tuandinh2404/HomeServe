package com.app.homeserve.ui.admin.phanviec;

import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.app.homeserve.R;
import com.app.homeserve.data.model.YeuCau;

import java.util.ArrayList;
import java.util.List;

// Bàn phân việc (tab "Phân việc" của Quản trị).
// Chuyển từ MainActivity cũ sang: onCreate → onViewCreated, MainActivity.this → requireContext().
public class BanPhanViecFragment extends Fragment {

    private RecyclerView recyclerView;
    private YeuCauAdapter adapter;
    private List<YeuCau> danhSachYeuCau;

    public BanPhanViecFragment() {
        super(R.layout.fragment_admin_phanviec);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        recyclerView = view.findViewById(R.id.recyclerViewYeuCau);
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));

        // 1. Tạo dữ liệu giả để test
        danhSachYeuCau = new ArrayList<>();
        danhSachYeuCau.add(new YeuCau(1, "Sửa máy lạnh không lạnh", "Phòng 101, Chung cư X", "14:00, Hôm nay", "Chờ nhận"));
        danhSachYeuCau.add(new YeuCau(2, "Thay ống nước bị bục", "123 Lê Lợi, Quận 1", "Càng sớm càng tốt", "Chờ nhận"));
        danhSachYeuCau.add(new YeuCau(3, "Sửa chập điện", "45 Nguyễn Trãi, Quận 5", "18:00, 10/11/2026", "Đang xử lý"));

        // 2. Khởi tạo Adapter và gắn sự kiện bấm vào từng thẻ Yêu Cầu
        adapter = new YeuCauAdapter(danhSachYeuCau, yeuCau -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
            View dialogView = getLayoutInflater().inflate(R.layout.dialog_phan_cong, null);
            builder.setView(dialogView);
            AlertDialog dialog = builder.create();

            TextView tvChiTiet = dialogView.findViewById(R.id.tvChiTietSuaChua);
            Spinner spinnerTho = dialogView.findViewById(R.id.spinnerTho);
            Button btnHuy = dialogView.findViewById(R.id.btnHuy);
            Button btnGiaoViec = dialogView.findViewById(R.id.btnGiaoViec);

            tvChiTiet.setText(yeuCau.tenDichVu + " - " + yeuCau.diaChi);

            // Đổ danh sách thợ giả lập
            String[] danhSachTho = {"Nguyễn Văn A (5 sao)", "Trần Văn B (4.5 sao)", "Lê Văn C (4 sao)"};
            ArrayAdapter<String> spinnerAdapter = new ArrayAdapter<>(
                    requireContext(), android.R.layout.simple_spinner_dropdown_item, danhSachTho);
            spinnerTho.setAdapter(spinnerAdapter);

            btnHuy.setOnClickListener(v -> dialog.dismiss());
            btnGiaoViec.setOnClickListener(v -> {
                Toast.makeText(requireContext(),
                        "Đã gán việc cho: " + spinnerTho.getSelectedItem().toString(),
                        Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });

            dialog.show();
        });

        recyclerView.setAdapter(adapter);
    }
}
