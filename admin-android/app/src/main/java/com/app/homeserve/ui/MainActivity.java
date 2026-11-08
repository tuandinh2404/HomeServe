package com.app.homeserve.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.app.homeserve.R;
import com.app.homeserve.adapters.YeuCauAdapter;
import com.app.homeserve.models.YeuCau;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private YeuCauAdapter adapter;
    private List<YeuCau> danhSachYeuCau;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        recyclerView = findViewById(R.id.recyclerViewYeuCau);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        // 1. Tạo dữ liệu giả để test
        danhSachYeuCau = new ArrayList<>();
        danhSachYeuCau.add(new YeuCau(1, "Sửa máy lạnh không lạnh", "Phòng 101, Chung cư X", "14:00, Hôm nay", "Chờ nhận"));
        danhSachYeuCau.add(new YeuCau(2, "Thay ống nước bị bục", "123 Lê Lợi, Quận 1", "Càng sớm càng tốt", "Chờ nhận"));
        danhSachYeuCau.add(new YeuCau(3, "Sửa chập điện", "45 Nguyễn Trãi, Quận 5", "18:00, 10/11/2026", "Đang xử lý"));

        // 2. Khởi tạo Adapter và gắn sự kiện bấm vào từng thẻ Yêu Cầu
        adapter = new YeuCauAdapter(danhSachYeuCau, yeuCau -> {
            // Hiển thị Dialog phân công
            AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
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
                    MainActivity.this, android.R.layout.simple_spinner_dropdown_item, danhSachTho);
            spinnerTho.setAdapter(spinnerAdapter);

            btnHuy.setOnClickListener(v -> dialog.dismiss());
            btnGiaoViec.setOnClickListener(v -> {
                Toast.makeText(MainActivity.this,
                        "Đã gán việc cho: " + spinnerTho.getSelectedItem().toString(),
                        Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });

            dialog.show();
        });

        recyclerView.setAdapter(adapter);
    }
}