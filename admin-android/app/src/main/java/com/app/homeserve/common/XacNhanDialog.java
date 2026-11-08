package com.app.homeserve.common;

import android.content.Context;

import androidx.annotation.Nullable;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;

// Hộp hỏi lại trước khi làm việc không hoàn tác được: xóa, từ chối, duyệt, gán thợ.
// Chỉ gọi API trong khiDongY, tức là SAU khi người dùng bấm nút đồng ý.
//
//   XacNhanDialog.hoiXoa(requireContext(), "danh mục Điện", () -> goiApiXoa(danhMuc));
//       → "Xóa danh mục Điện?"   [Hủy] [Xóa]
//
//   XacNhanDialog.hoi(requireContext(), "Giao việc cho Nguyễn Văn B?", null, "Giao việc",
//           () -> goiApiPhanCong(tho));
//       → "Giao việc cho Nguyễn Văn B?"   [Hủy] [Giao việc]
public final class XacNhanDialog {

    private XacNhanDialog() { }

    public static void hoi(Context context, String tieuDe, @Nullable String noiDung,
                           String nutDongY, Runnable khiDongY) {
        MaterialAlertDialogBuilder hop = new MaterialAlertDialogBuilder(context)
                .setTitle(tieuDe)
                .setNegativeButton("Hủy", (d, i) -> d.dismiss())
                .setPositiveButton(nutDongY, (d, i) -> khiDongY.run());
        if (noiDung != null) hop.setMessage(noiDung);
        hop.show();
    }

    // Mẫu riêng cho xóa, vì xóa là việc hay gặp nhất (yêu cầu bắt buộc của môn)
    public static void hoiXoa(Context context, String tenThuCanXoa, Runnable khiDongY) {
        hoi(context, "Xóa " + tenThuCanXoa + "?", "Không thể hoàn tác sau khi xóa.", "Xóa", khiDongY);
    }
}
