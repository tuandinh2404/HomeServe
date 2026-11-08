package com.app.homeserve.common;

import android.app.Activity;
import android.content.Intent;

import com.app.homeserve.ui.admin.AdminMainActivity;
import com.app.homeserve.ui.auth.LoginActivity;
import com.app.homeserve.ui.tho.ThoMainActivity;

// Mở màn hình chính đúng theo vai trò. Splash và Login cùng dùng, để chỉ viết 1 lần.
//   QUAN_TRI → AdminMainActivity,  THO → ThoMainActivity
//   KHACH hoặc vai trò lạ → trả false, nơi gọi tự xử lý (Login báo lỗi, Splash về Login)
public final class DieuHuong {

    private DieuHuong() { }

    public static boolean moManChinh(Activity tu, String vaiTro) {
        Class<?> manChinh;
        if (HangSo.VaiTro.QUAN_TRI.equals(vaiTro)) manChinh = AdminMainActivity.class;
        else if (HangSo.VaiTro.THO.equals(vaiTro)) manChinh = ThoMainActivity.class;
        else return false;
        moVaXoaManCu(tu, manChinh);
        return true;
    }

    public static void moDangNhap(Activity tu) {
        moVaXoaManCu(tu, LoginActivity.class);
    }

    // CLEAR_TASK: xóa các màn trước đó, bấm Back ở màn mới sẽ thoát app
    // chứ không quay về Splash / Login.
    private static void moVaXoaManCu(Activity tu, Class<?> man) {
        Intent intent = new Intent(tu, man);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        tu.startActivity(intent);
        tu.finish();
    }
}
