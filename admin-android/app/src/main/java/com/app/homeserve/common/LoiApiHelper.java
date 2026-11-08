package com.app.homeserve.common;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import okhttp3.ResponseBody;
import retrofit2.Response;

// Đọc lỗi server trả về theo quy ước api.md:  { "loi": "Thông báo", "truong": "email" }
// Cách dùng trong onResponse, khi !response.isSuccessful():
//   String thongBao = LoiApiHelper.thongBao(response);          // chỉ cần câu thông báo
//   LoiApiHelper.Loi loi = LoiApiHelper.doc(response);           // cần biết ô nhập nào sai
//   if ("email".equals(loi.truong)) edtEmail.setError(loi.thongBao);
// Trong onFailure (mất mạng, server ngủ, hết giờ chờ) dùng LoiApiHelper.LOI_MANG.
// Lưu ý: errorBody chỉ đọc được 1 lần, nên mỗi response chỉ gọi doc() hoặc thongBao() 1 lần.
public final class LoiApiHelper {

    public static final String LOI_MANG = "Không có kết nối mạng. Kiểm tra mạng rồi thử lại";

    private LoiApiHelper() { }

    // Kết quả đọc được: câu thông báo (luôn có) + tên ô nhập bị sai (có thể null)
    public static final class Loi {
        public final String thongBao;
        public final String truong;

        Loi(String thongBao, String truong) {
            this.thongBao = thongBao;
            this.truong = truong;
        }
    }

    public static Loi doc(Response<?> response) {
        String thongBao = null;
        String truong = null;
        try (ResponseBody body = response.errorBody()) {
            if (body != null) {
                JsonObject json = JsonParser.parseString(body.string()).getAsJsonObject();
                thongBao = chuoiHoacNull(json, "loi");
                truong = chuoiHoacNull(json, "truong");
            }
        } catch (Exception e) {
            // Body không phải JSON đúng mẫu (ví dụ trang lỗi HTML của Render) → dùng câu mặc định
        }
        if (thongBao == null || thongBao.isEmpty()) thongBao = cauMacDinh(response.code());
        return new Loi(thongBao, truong);
    }

    public static String thongBao(Response<?> response) {
        return doc(response).thongBao;
    }

    private static String chuoiHoacNull(JsonObject json, String khoa) {
        JsonElement e = json.get(khoa);
        return (e == null || e.isJsonNull()) ? null : e.getAsString();
    }

    // Câu dùng khi server không gửi "loi". Sửa chữ ở đây nếu muốn đổi cách báo.
    private static String cauMacDinh(int ma) {
        if (ma == 400) return "Dữ liệu gửi lên chưa đúng";
        if (ma == 401) return "Phiên đăng nhập đã hết, hãy đăng nhập lại";
        if (ma == 403) return "Bạn không có quyền làm việc này";
        if (ma == 404) return "Không tìm thấy dữ liệu, có thể đã bị xóa";
        if (ma == 409) return "Dữ liệu vừa thay đổi, hãy tải lại rồi thử lại";
        if (ma >= 500) return "Lỗi máy chủ, thử lại sau";
        return "Có lỗi xảy ra (mã " + ma + ")";
    }
}
