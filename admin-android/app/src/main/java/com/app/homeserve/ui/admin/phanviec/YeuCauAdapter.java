package com.app.homeserve.ui.admin.phanviec;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.app.homeserve.R;
import com.app.homeserve.data.model.YeuCau;
import java.util.List;

public class YeuCauAdapter extends RecyclerView.Adapter<YeuCauAdapter.YeuCauViewHolder> {

    private List<YeuCau> danhSachYeuCau;
    private OnItemClickListener listener;

    // Interface để xử lý sự kiện bấm vào từng dòng (phục vụ việc gán thợ sau này)
    public interface OnItemClickListener {
        void onItemClick(YeuCau yeuCau);
    }

    public YeuCauAdapter(List<YeuCau> danhSachYeuCau, OnItemClickListener listener) {
        this.danhSachYeuCau = danhSachYeuCau;
        this.listener = listener;
    }

    public void setDanhSach(List<YeuCau> danhSachMoi) {
        this.danhSachYeuCau = danhSachMoi;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public YeuCauViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_yeu_cau, parent, false);
        return new YeuCauViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull YeuCauViewHolder holder, int position) {
        YeuCau yeuCau = danhSachYeuCau.get(position);
        holder.tvTenDichVu.setText(yeuCau.tenDichVu);
        holder.tvDiaChi.setText(yeuCau.diaChi);
        holder.tvThoiGian.setText(yeuCau.thoiGianMongMuon);
        holder.tvTrangThai.setText(yeuCau.trangThai);

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onItemClick(yeuCau);
        });
    }

    @Override
    public int getItemCount() {
        return danhSachYeuCau != null ? danhSachYeuCau.size() : 0;
    }

    static class YeuCauViewHolder extends RecyclerView.ViewHolder {
        TextView tvTenDichVu, tvDiaChi, tvThoiGian, tvTrangThai;

        public YeuCauViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTenDichVu = itemView.findViewById(R.id.tvTenDichVu);
            tvDiaChi = itemView.findViewById(R.id.tvDiaChi);
            tvThoiGian = itemView.findViewById(R.id.tvThoiGian);
            tvTrangThai = itemView.findViewById(R.id.tvTrangThai);
        }
    }
}