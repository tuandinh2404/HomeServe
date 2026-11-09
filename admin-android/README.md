# HomeServe – App Admin (Android)

App Android dành cho **2 vai trò**:

- **Quản trị viên (`QUAN_TRI`)**: quản lý danh mục và bảng giá, phân việc cho thợ, duyệt hồ sơ thợ, xem xét báo giá vượt trần, xử lý khiếu nại, xem báo cáo.
- **Thợ (`THO`)**: gửi hồ sơ, nhận việc được giao, cập nhật trạng thái công việc, gửi báo giá.

Khách hàng **không** dùng app này. Khách dùng app Flutter.

Đăng nhập xong, app đọc vai trò và mở đúng phần: `QUAN_TRI` vào `AdminMainActivity`, `THO` vào `ThoMainActivity`. Tài khoản `KHACH` đăng nhập vào đây thì bị chặn, app báo *"Tài khoản này dùng app khách hàng"*.

| | |
|---|---|
| Ngôn ngữ | Java + XML (không dùng Kotlin, không dùng Compose) |
| minSdk | 24 |
| Gọi API | Retrofit 2 + Gson |
| Biểu đồ | MPAndroidChart (chỉ phần báo cáo của Tuấn) |
| Backend | Node + Express, deploy trên Render |
| Tài liệu API | `backend/api.md` trên nhánh `backend`. **Đây là nguồn chuẩn**: đường dẫn, tên trường, mã lỗi đều lấy theo file này. README chỉ tóm tắt; khi README và `api.md` khác nhau thì làm theo `api.md` |

### Ai làm gì trong app này

| Người | Phần |
|---|---|
| **Tuấn** (nhóm trưởng) | Khung dùng chung (`data/`, `common/`), Splash, 2 MainActivity + thanh tab, báo cáo + biểu đồ, công nợ thợ. Xem mọi PR |
| **Thông** | **Màn đăng nhập** (mục 5.0) và toàn bộ màn hình nghiệp vụ của Quản trị và Thợ (mục 5.1–5.8) |
| Tâm | Backend (API). Hỏi Tâm khi API trả sai |

---

## 1. Chạy app

1. Mở Android Studio → **Open** → chọn thư mục `admin-android/`. Không mở thư mục gốc của repo.
2. Chờ Gradle sync xong. Sync lỗi thì chụp màn hình gửi Tuấn, đừng tự đổi phiên bản thư viện.
3. Địa chỉ backend nằm trong `app/build.gradle.kts`, dòng `buildConfigField("String", "BASE_URL", ...)`, hiện là **`https://homeserve-vm96.onrender.com/`**. **Không tự sửa dòng này.** Khi đổi server, Tuấn sẽ sửa. Mở link đó + `health` trên trình duyệt điện thoại thấy `{"ok":true,...}` là server đang chạy.
4. Chạy trên điện thoại thật hoặc máy ảo. Server đã có UptimeRobot gọi định kỳ nên thường không ngủ. Nếu lần đầu gọi API mất 30–50 giây thì là server vừa khởi động lại (vd ngay sau khi merge backend), không phải lỗi app.

Tài khoản thử (có trong `sql/seed-tai-khoan.sql` của backend), **mật khẩu đều là `123456`**:

| Vai trò | Email | Ghi chú |
|---|---|---|
| Quản trị | `quantri@homeserve.vn` | Vào 4 tab Quản trị |
| Thợ đã duyệt | `tho.dien@homeserve.vn` | Vào 2 tab Thợ. Nghề Điện, Quận 1 |
| Thợ chờ duyệt | `tho.choduyet@homeserve.vn` | Vào 2 tab Thợ, hồ sơ đang chờ duyệt |
| Khách hàng | `khach@homeserve.vn` | Dùng để thử **bị chặn**: app phải báo *"Tài khoản này dùng app khách hàng"* |

---

## 2. Cấu trúc thư mục

```
app/src/main/java/com/app/homeserve/
├── data/                         [DÙNG CHUNG – Tuấn dựng, Thông chỉ dùng]
│   ├── api/
│   │   ├── ApiClient.java        Tạo Retrofit 1 lần, tự gắn token, gặp 401 thì về đăng nhập
│   │   ├── AuthApi.java          [Thông bổ sung hàm]
│   │   ├── DanhMucApi.java       [Thông bổ sung hàm]
│   │   ├── HoSoThoApi.java       [Thông bổ sung hàm]
│   │   ├── YeuCauApi.java        [Thông bổ sung hàm]
│   │   ├── BaoGiaApi.java        [Thông bổ sung hàm]
│   │   ├── KhieuNaiApi.java      [Thông bổ sung hàm]
│   │   └── BaoCaoApi.java        [Tuấn]
│   ├── model/                    Lớp dữ liệu khớp JSON: NguoiDung, DanhMuc, DichVu, HoSoTho,
│   │                             YeuCau, PhanCong, BaoGiaChiTiet, KhieuNai, LoiApi
│   └── TokenStore.java           Lưu / đọc / xóa token và vai trò
├── common/                       [DÙNG CHUNG – Tuấn]
│   ├── HangSo.java               Vai trò và mọi trạng thái, viết y hệt api.md            ✅ đã có
│   ├── LoiApiHelper.java         Đọc {"loi": "...", "truong": "..."} từ response lỗi       ✅ đã có
│   ├── StateView.java            Khung 3 trạng thái: đang tải / có dữ liệu / rỗng / lỗi    ✅ đã có
│   ├── DieuHuong.java            Mở màn chính theo vai trò, mở màn đăng nhập             ✅ đã có
│   ├── XacNhanDialog.java        Hộp hỏi lại trước khi xóa / từ chối / giao việc           ✅ đã có
│   └── TienTe.java               150000 → "150.000 đ", đọc lại số từ ô nhập               ✅ đã có
└── ui/
    ├── auth/                     [Tuấn]   SplashActivity    [THÔNG]  LoginActivity
    ├── admin/
    │   ├── AdminMainActivity     [Tuấn]   Thanh tab dưới + gắn fragment
    │   ├── danhmuc/              [THÔNG]  Danh mục, dịch vụ, giá sàn / giá trần
    │   ├── hosotho/              [THÔNG]  Duyệt hồ sơ thợ
    │   ├── phanviec/             [THÔNG]  Bàn phân việc, tìm thợ phù hợp, gán thợ
    │   ├── baogia/               [THÔNG]  Báo giá vượt trần cần xem xét
    │   ├── khieunai/             [THÔNG]  Danh sách khiếu nại, ghi quyết định
    │   └── baocao/               [Tuấn]   Báo cáo có biểu đồ, công nợ thợ
    └── tho/
        ├── ThoMainActivity       [Tuấn]   Thanh tab dưới cho Thợ
        ├── hoso/                 [THÔNG]  Gửi / cập nhật hồ sơ thợ
        ├── viec/                 [THÔNG]  Việc được giao, nhận / từ chối, đổi trạng thái
        └── baogia/               [THÔNG]  Tạo các dòng báo giá
```

### Code Java và layout nằm ở 2 chỗ khác nhau

```
app/src/main/
├── java/com/app/homeserve/    ← code Java, chia thư mục theo tính năng (cây ở trên)
└── res/                       ← giao diện và tài nguyên
    ├── layout/                ← TẤT CẢ layout XML nằm chung ở đây
    ├── menu/                  ← menu thanh tab
    ├── drawable/              ← icon, hình
    └── values/                ← chữ, màu, theme
```

**`res/layout/` không được có thư mục con.** Android chỉ đọc file nằm thẳng trong `layout/`, nên không thể làm `layout/danhmuc/...`. Layout của mọi người nằm chung một chỗ, vì vậy **tên file phải cho biết nó thuộc màn hình nào** (quy tắc đặt tên ở cuối mục này).

Mỗi Activity / Fragment đi kèm 1 layout. Mỗi Adapter đi kèm 1 layout `item_` (giao diện của **1 dòng** trong danh sách). Ví dụ tính năng danh mục:

| Java (`java/.../ui/admin/danhmuc/`) | Layout (`res/layout/`) | Là gì |
|---|---|---|
| `DanhMucFragment.java` | `fragment_admin_danhmuc.xml` | Màn danh sách danh mục |
| `DanhMucAdapter.java` | `item_danh_muc.xml` | 1 dòng danh mục |
| `DichVuListActivity.java` | `activity_dich_vu_list.xml` | Màn danh sách dịch vụ |
| `DichVuAdapter.java` | `item_dich_vu.xml` | 1 dòng dịch vụ |
| `DichVuFormActivity.java` | `activity_dich_vu_form.xml` | Form thêm / sửa |

### Toàn bộ thư mục `res/`

```
res/
├── layout/
│   │  ── Tuấn ──
│   ├── activity_splash.xml
│   ├── activity_login.xml
│   ├── activity_admin_main.xml
│   ├── activity_tho_main.xml
│   ├── view_state.xml                    (khung đang tải / lỗi dùng chung)
│   ├── fragment_admin_baocao.xml
│   │
│   │  ── Thông: Quản trị ──
│   ├── fragment_admin_danhmuc.xml        item_danh_muc.xml
│   ├── activity_dich_vu_list.xml         item_dich_vu.xml
│   ├── activity_dich_vu_form.xml
│   ├── fragment_admin_hosotho.xml        item_ho_so_tho.xml
│   ├── activity_chi_tiet_ho_so_tho.xml
│   ├── fragment_admin_phanviec.xml       item_yeu_cau.xml
│   ├── activity_chi_tiet_yeu_cau.xml     item_tho_phu_hop.xml
│   ├── fragment_admin_baogia.xml         item_bao_gia_vuot_tran.xml
│   ├── fragment_admin_khieunai.xml       item_khieu_nai.xml
│   ├── activity_chi_tiet_khieu_nai.xml
│   │
│   │  ── Thông: Thợ ──
│   ├── fragment_tho_viec.xml             item_viec.xml
│   ├── activity_chi_tiet_viec.xml
│   ├── fragment_tho_hoso.xml
│   └── activity_tao_bao_gia.xml          item_dong_bao_gia.xml
│
├── menu/
│   ├── menu_admin.xml                    (4 tab Quản trị – Tuấn)
│   └── menu_tho.xml                      (2 tab Thợ – Tuấn)
│
└── values/
    ├── strings.xml                       (chung – Tuấn)
    ├── strings_danhmuc.xml               ┐
    ├── strings_phanviec.xml              │ mỗi tính năng 1 file,
    ├── strings_hosotho.xml               │ Thông làm
    ├── strings_baogia.xml                │
    ├── strings_khieunai.xml              │
    ├── strings_tho.xml                   ┘
    ├── colors.xml
    └── themes.xml
```

Trong Android Studio, cột bên trái để chế độ xem **Android** (mặc định) sẽ thấy 2 nhánh `java` và `res` đúng như trên.

**Mẹo:** bấm `Shift` 2 lần rồi gõ `item_` hoặc `fragment_admin_` là thấy ngay mọi layout cùng nhóm.

**Tạo Activity mới:** chuột phải vào package → **New → Activity → Empty Views Activity**, Language **Java**. Android Studio tự tạo file Java + layout. Không chọn **Empty Activity**, vì đó là Jetpack Compose (Kotlin). Sau đó báo Tuấn để kiểm tra khai báo trong Manifest.

### Thanh tab của mỗi vai trò (Tuấn gắn sẵn)

| Quản trị (`AdminMainActivity`) | Thợ (`ThoMainActivity`) |
|---|---|
| Phân việc → `phanviec/BanPhanViecFragment` | Việc của tôi → `viec/ViecCuaToiFragment` |
| Danh mục → `danhmuc/DanhMucFragment` | Hồ sơ → `hoso/HoSoFragment` |
| Duyệt → `hosotho/` + `baogia/` + `khieunai/` (3 tab con) | Đăng xuất (trong menu) |
| Báo cáo → `baocao/BaoCaoFragment` | |

Mỗi Fragment trên đã có sẵn **file trống**, đã gắn vào tab, đã khai báo Activity trong Manifest. Thông mở file ra và làm.

### Quy tắc file

- **Chỉ sửa trong thư mục của mình.** Thư mục `[THÔNG]` thì Thông làm toàn quyền.
- Được thêm hàm vào các file `XxxApi.java` có ghi `[Thông bổ sung hàm]` và thêm lớp vào `data/model/`.
- **Không sửa** `ApiClient`, `TokenStore`, `common/`, `AndroidManifest.xml`, `build.gradle.kts`. Cần đổi thì nhắn Tuấn, hoặc mở một PR riêng chỉ chứa thay đổi đó. Những file này ai cũng dùng, sửa lẫn nhau rất dễ đè code.
- Cần Activity mới thì báo Tuấn khai báo trong Manifest.
- Chuỗi hiển thị đặt trong file strings riêng của tính năng: `res/values/strings_danhmuc.xml`, `strings_phanviec.xml`, `strings_hosotho.xml`, `strings_baogia.xml`, `strings_khieunai.xml`, `strings_tho.xml`. Không thêm vào `strings.xml` chung.

### Đặt tên

| Loại | Mẫu | Ví dụ |
|---|---|---|
| Màn hình danh sách | `<TinhNang>Fragment` | `DanhMucFragment.java` |
| Màn hình chi tiết | `ChiTiet<DoiTuong>Activity` | `ChiTietYeuCauActivity.java` |
| Form thêm / sửa | `<DoiTuong>FormActivity` | `DichVuFormActivity.java` |
| Adapter | `<DoiTuong>Adapter` | `DichVuAdapter.java` |
| Layout | `activity_…`, `fragment_<vai_tro>_<tinh_nang>`, `item_…` | `fragment_admin_danhmuc.xml`, `item_dich_vu.xml` |
| id trong XML | `<loại>_<tên>` | `rv_dich_vu`, `edt_gia_tran`, `btn_luu`, `tv_ten` |

---

## 3. Khung dùng chung: cách dùng

Tên hàm cụ thể xem trong code khung. Bảng dưới cho biết **file nào dùng để làm gì**.

| File | Dùng khi | Ghi nhớ |
|---|---|---|
| `ApiClient` | Gọi bất kỳ API nào | Token tự gắn vào header. **Không** tự thêm `Authorization`. Gặp `401` thì ApiClient tự xóa token và về màn đăng nhập, màn hình của mình không cần xử lý `401` |
| `TokenStore` | Cần biết người đang đăng nhập là ai, vai trò gì | Chỉ đọc, không tự ghi |
| `HangSo` | So sánh vai trò / trạng thái, hiện trạng thái cho người dùng | Viết `HangSo.TrangThaiYeuCau.CHO_NHAN`, **không** gõ tay `"CHO_NHAN"`. Hiện chữ tiếng Việt: `HangSo.tenHienThi(yeuCau.trangThai)` → "Chờ nhận" |
| `LoiApiHelper` | Response không thành công (400, 403, 404, 409, 500) | `LoiApiHelper.thongBao(res)` → câu để hiện. Cần biết ô nào sai thì `LoiApiHelper.doc(res)` → `.thongBao` + `.truong`. Mất mạng dùng `LoiApiHelper.LOI_MANG`. Mỗi response chỉ đọc lỗi **1 lần** |
| `StateView` | Mọi màn hình có gọi API | Bọc RecyclerView trong layout (xem mẫu dưới). `showLoading()` → `showContent()` / `showEmpty("...")` / `showError("...")`. Gắn `setOnThuLai(...)` thì lỗi có nút **Thử lại** |
| `DieuHuong` | Sau khi đăng nhập xong | `DieuHuong.moManChinh(this, vaiTro)` tự mở Admin hoặc Thợ và xóa màn cũ. Trả `false` nếu vai trò là `KHACH` / lạ |
| `XacNhanDialog` | Xóa, từ chối, duyệt, gán thợ | Xóa: `XacNhanDialog.hoiXoa(requireContext(), "danh mục Điện", () -> goiApiXoa(dm))` → *"Xóa danh mục Điện?"* [Hủy] [Xóa]. Việc khác: `XacNhanDialog.hoi(ctx, "Giao việc cho Nguyễn Văn B?", null, "Giao việc", () -> ...)`. **Gọi API bên trong `() -> ...`**, đoạn đó chỉ chạy khi người dùng bấm đồng ý |
| `TienTe` | Hiện số tiền, đọc số tiền từ ô nhập | `TienTe.hien(150000)` → "150.000 đ". `TienTe.khoang(giaSan, giaTran)` → "80.000 – 150.000 đ". `TienTe.doc(edtGia.getText().toString())` → `150000`, hoặc `null` nếu người dùng gõ sai (form báo lỗi ô đó). Gửi lên API vẫn là số nguyên `long` |

### Mẫu một màn danh sách có gọi API

**Layout:** bọc RecyclerView bằng `StateView`. StateView tự thêm vòng xoay, câu thông báo và nút Thử lại đè lên trên.

```xml
<com.app.homeserve.common.StateView xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/state_view"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_danh_muc"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</com.app.homeserve.common.StateView>
```

**Fragment:**

```java
private StateView stateView;

@Override
public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    stateView = view.findViewById(R.id.state_view);
    stateView.setOnThuLai(this::taiDuLieu);      // bấm "Thử lại" thì gọi lại API
    // ... gắn RecyclerView + adapter ...
    taiDuLieu();
}

private void taiDuLieu() {
    stateView.showLoading();
    ApiClient.get(requireContext()).create(DanhMucApi.class).layDanhMuc().enqueue(new Callback<List<DanhMuc>>() {
        @Override public void onResponse(Call<List<DanhMuc>> call, Response<List<DanhMuc>> res) {
            if (!res.isSuccessful()) {
                stateView.showError(LoiApiHelper.thongBao(res));   // câu "loi" từ server
            } else if (res.body() == null || res.body().isEmpty()) {
                stateView.showEmpty("Chưa có danh mục nào");
            } else {
                adapter.submit(res.body());
                stateView.showContent();
            }
        }
        @Override public void onFailure(Call<List<DanhMuc>> call, Throwable t) {
            stateView.showError(LoiApiHelper.LOI_MANG);   // mất mạng, server ngủ, hết thời gian chờ
        }
    });
}
```

*`DanhMucApi.layDanhMuc()` và `adapter.submit()` là hàm Thông tự viết. `ApiClient`, `StateView`, `LoiApiHelper` là tên thật trong khung.*

---

## 4. Quy ước dữ liệu (tóm tắt mục 1 của `api.md`)

- **Tên trường JSON là `snake_case`**, khớp tên cột CSDL. Trong model dùng `@SerializedName`:
  ```java
  @SerializedName("gia_tran") public long giaTran;
  @SerializedName("danh_muc_id") public int danhMucId;
  ```
- **Tiền** là số nguyên VND (`150000`). Dùng `long`, **không** dùng `double` hay `float`.
- **Ngày giờ** là chuỗi ISO 8601: `2026-11-02T14:00:00+07:00`. Hiện ra màn hình dạng `14:00 · 02/11/2026`.
- **Lỗi** có dạng `{ "loi": "Thông báo cho người dùng" }`. Nếu có thêm `"truong": "gia_tran"` thì báo lỗi ngay dưới ô nhập đó (`setError`), không dùng Toast.
- **Danh sách dài** (yêu cầu, khiếu nại) có phân trang `?trang=1&soLuong=20`. Cuộn tới cuối thì tải trang tiếp.

### Mã HTTP và app phải làm gì

| Mã | Nghĩa | App làm gì |
|---|---|---|
| 200 / 201 | Thành công | Cập nhật danh sách, đóng form, Toast ngắn "Đã lưu" |
| 400 | Dữ liệu sai | Hiện `loi` dưới ô nhập (nếu có `truong`), giữ nguyên form |
| 401 | Token hỏng / hết hạn | **Không cần làm gì**, ApiClient đã tự xử lý |
| 403 | Sai vai trò hoặc không phải dữ liệu của mình | Hiện `loi`, quay lại màn trước |
| 404 | Không tìm thấy (có thể người khác vừa xóa) | Hiện `loi`, tải lại danh sách |
| 409 | Xung đột: xóa thứ đang được dùng, trùng tên, chuyển trạng thái sai thứ tự | Hiện `loi`, **không** xóa / đổi trên giao diện |
| 500 | Lỗi server | "Lỗi máy chủ, thử lại sau", báo Tâm |

### Giá trị cố định (có trong `HangSo.java`)

| Trường | Trong code | Giá trị | `HangSo.tenHienThi()` trả về |
|---|---|---|---|
| Vai trò | `HangSo.VaiTro.*` | `KHACH`, `THO`, `QUAN_TRI` | Khách hàng, Thợ, Quản trị |
| `ho_so_tho.trang_thai_duyet` | `HangSo.TrangThaiDuyet.*` | `CHO_DUYET`, `DA_DUYET`, `TU_CHOI` | Chờ duyệt, Đã duyệt, Từ chối |
| `yeu_cau.trang_thai` | `HangSo.TrangThaiYeuCau.*` | `CHO_NHAN`, `DA_NHAN`, `DANG_LAM`, `HOAN_TAT`, `HUY` | Chờ nhận, Đã nhận, Đang làm, Hoàn tất, Đã hủy |
| `phan_cong.trang_thai` | `HangSo.TrangThaiPhanCong.*` | `CHO_THO_NHAN`, `DA_NHAN`, `TU_CHOI` | Chờ thợ nhận, Đã nhận, Từ chối |
| `khieu_nai.trang_thai` | `HangSo.TrangThaiKhieuNai.*` | `MOI`, `DANG_XU_LY`, `DA_XU_LY` | Mới, Đang xử lý, Đã xử lý |

`DA_NHAN` và `TU_CHOI` có ở 2 nhóm, nên `HangSo` chia theo nhóm: gõ `HangSo.TrangThaiYeuCau.` là Android Studio chỉ gợi ý đúng 5 mã của yêu cầu.

Đơn chỉ được đi theo thứ tự `CHO_NHAN → DA_NHAN → DANG_LAM → HOAN_TAT`. Hủy (`HUY`) chỉ được khi chưa tới `DANG_LAM`. **Chỉ hiện nút cho bước tiếp theo hợp lệ.** Ví dụ đơn đang `DA_NHAN` thì chỉ hiện "Bắt đầu làm", không hiện "Hoàn tất". Server vẫn kiểm tra lại và trả `409` nếu sai.

---

## 5. Chi tiết từng màn hình của Thông

Mỗi màn hình bên dưới ghi: **file cần tạo → màn hình hiện gì → bấm vào làm gì → gọi API nào → lỗi phải xử lý → yêu cầu môn học nó đáp ứng**.

### 5.0 `auth/LoginActivity`: Đăng nhập *(tuần 10, mốc kiểm tra tuần 11)*

Thông đã làm bản đầu trên nhánh `android-lam-truoc`. Chuyển vào `ui/auth/LoginActivity.java` + `activity_login.xml` có sẵn trong khung, làm trên nhánh `android-dang-nhap`.

**File:**
```
ui/auth/LoginActivity.java          activity_login.xml
data/model/YeuCauDangNhap.java      (gửi lên)
data/model/KetQuaDangNhap.java      (nhận về)
data/model/NguoiDung.java           (bên trong KetQuaDangNhap)
data/api/AuthApi.java               thêm hàm dangNhap
```

**API:** `POST /auth/dang-nhap`. Gửi `{ "email", "mat_khau" }`, nhận `{ "token", "nguoi_dung": { "id", "ho_ten", "vai_tro" } }`.

**Màn hình:** ô Email, ô Mật khẩu, nút Đăng nhập, vòng xoay khi đang gửi.

| Bước | Làm gì |
|---|---|
| Bấm Đăng nhập | Kiểm tra trên app: email không rỗng + đúng định dạng (`Patterns.EMAIL_ADDRESS`), mật khẩu không rỗng. Sai thì `setError` ngay dưới ô, **không** dùng Toast, không gọi API |
| Đang gửi | Hiện vòng xoay, **khóa nút** Đăng nhập để không bấm 2 lần |
| Thành công, vai trò `QUAN_TRI` / `THO` | `TokenStore.get(this).luu(token, vaiTro, hoTen)` rồi `DieuHuong.moManChinh(this, vaiTro)` |
| Thành công, vai trò `KHACH` | **Không lưu gì**, báo *"Tài khoản này dùng app khách hàng"* |
| Server báo lỗi (401 sai mật khẩu, 400...) | `LoiApiHelper.doc(res)`: có `truong` thì `setError` ở ô đó, không thì hiện `thongBao` |
| Mất mạng | `LoiApiHelper.LOI_MANG` |

**Bắt buộc:** model dùng `@SerializedName` vì server dùng snake_case:
```java
@SerializedName("mat_khau") public String matKhau;
@SerializedName("nguoi_dung") public NguoiDung nguoiDung;
@SerializedName("ho_ten") public String hoTen;
@SerializedName("vai_tro") public String vaiTro;
```
Thiếu `@SerializedName` thì server không thấy mật khẩu (trả 400), và app đọc về `nguoiDung` bằng `null`.

**Thử:** đăng nhập bằng tài khoản Quản trị → vào 4 tab Quản trị. Tắt app mở lại → vào thẳng, không hỏi đăng nhập (Splash đọc token). Tài khoản Thợ → vào 2 tab Thợ. Sai mật khẩu → hiện *"Email hoặc mật khẩu không đúng"*.

### 5.1 `admin/danhmuc/`: Danh mục và bảng giá *(tuần 10–11, mốc kiểm tra)*

**File:**
```
DanhMucFragment.java        fragment_admin_danhmuc.xml
DanhMucAdapter.java         item_danh_muc.xml
DichVuListActivity.java     activity_dich_vu_list.xml
DichVuAdapter.java          item_dich_vu.xml
DichVuFormActivity.java     activity_dich_vu_form.xml
```

**Màn danh sách danh mục** (`DanhMucFragment`)
- RecyclerView, mỗi dòng: tên danh mục + "8 dịch vụ" (`so_dich_vu`).
- Nút **+** (FloatingActionButton): hộp nhập tên → tạo danh mục mới.
- Bấm vào một dòng: mở `DichVuListActivity` của danh mục đó.
- Nhấn giữ một dòng: menu **Sửa tên** / **Xóa**.
- Xóa: `XacNhanDialog.hoiXoa(requireContext(), "danh mục " + dm.ten, () -> xoaDanhMuc(dm))` → đồng ý mới gọi API.

| Thao tác | API |
|---|---|
| Tải danh sách | `GET /danh-muc-dv` |
| Thêm | `POST /danh-muc-dv` `{ "ten" }` → 201 |
| Sửa tên | `PATCH /danh-muc-dv/:id` `{ "ten" }` |
| Xóa | `DELETE /danh-muc-dv/:id` |

Lỗi phải xử lý: `409` khi trùng tên → báo dưới ô nhập. `409` khi xóa danh mục còn dịch vụ → hiện `loi` ("Danh mục còn dịch vụ, không xóa được"), **không** bỏ dòng khỏi danh sách.

**Màn danh sách dịch vụ** (`DichVuListActivity`)
- RecyclerView, mỗi dòng: tên dịch vụ, đơn vị, **"80.000 – 150.000 đ / cái"** (giá sàn – giá trần): `TienTe.khoang(dv.giaSan, dv.giaTran) + " / " + dv.donVi`.
- Nút **+**: mở `DichVuFormActivity` để thêm. Bấm một dòng: mở form để sửa.
- Nhấn giữ → Xóa → `XacNhanDialog.hoiXoa(...)`.

| Thao tác | API |
|---|---|
| Tải danh sách | `GET /dich-vu?danhMucId=<id>` |
| Xóa | `DELETE /dich-vu/:id` (409 khi đã có yêu cầu dùng dịch vụ này) |

**Form dịch vụ** (`DichVuFormActivity`)

| Ô nhập | Kiểu | Kiểm tra trên app |
|---|---|---|
| Tên | chữ | Không rỗng, tối đa 100 ký tự |
| Mô tả | chữ nhiều dòng | Không bắt buộc |
| Đơn vị | chữ (cái, m², lần, giờ) | Không rỗng |
| Giá sàn | số | Bắt buộc, > 0. Đọc bằng `TienTe.doc(...)`: trả `null` → báo *"Nhập số tiền hợp lệ"* |
| Giá trần | số | Bắt buộc, **≥ giá sàn** |

- Kiểm tra ngay khi bấm **Lưu**. Sai ô nào thì `setError` ở ô đó, không gọi API.
- Đúng hết: thêm thì `POST /dich-vu`, sửa thì `PATCH /dich-vu/:id`. Thành công → đóng form, trả kết quả về danh sách (`setResult(RESULT_OK)`) để danh sách tải lại.
- Đang gửi thì khóa nút Lưu, tránh bấm 2 lần tạo 2 bản ghi.

**Đáp ứng:** RecyclerView #1 và #2 · form kiểm tra hợp lệ đầy đủ · hộp xác nhận trước khi xóa · 3 trạng thái · *bảng giá tham chiếu (điểm nhấn ① cần giá trần đúng)*.

**Mốc tuần 11:** màn này phải chạy bằng **API thật** trên server đã deploy. Thầy sẽ thử: thêm dịch vụ ở app Android → app Flutter thấy ngay.

---

### 5.2 `tho/hoso/`: Thợ gửi hồ sơ *(tuần 12)*

**File:** `HoSoFragment.java` · `fragment_tho_hoso.xml`

- Hiện trạng thái duyệt ở đầu màn: **Chờ duyệt** / **Đã duyệt** / **Từ chối** (kèm lý do nếu có).
- Form: nghề (chọn nhiều danh mục, lấy từ `GET /danh-muc-dv`), khu vực, chứng chỉ (ảnh, tải lên qua `POST /tai-len` lấy URL).
- Bấm **Gửi hồ sơ** → `POST /tho/ho-so`. Sau khi gửi, trạng thái về **Chờ duyệt**.
- Thợ chưa được duyệt: tab "Việc của tôi" hiện thông báo "Hồ sơ đang chờ duyệt", không có danh sách việc.

Còn **[CẦN CHỐT]** trong `api.md`: thợ tự đăng ký (phương án a) hay quản trị tạo tài khoản (b). Nếu chọn (b), màn này chỉ còn cập nhật hồ sơ.

---

### 5.3 `admin/hosotho/`: Duyệt hồ sơ thợ *(tuần 12)*

**File:** `HoSoThoFragment.java` · `HoSoThoAdapter.java` · `ChiTietHoSoThoActivity.java` + layout

- Lọc theo trạng thái (Chờ duyệt / Đã duyệt / Từ chối) bằng chip hoặc tab. Mặc định: Chờ duyệt.
- Mỗi dòng: tên thợ, nghề, khu vực, ngày gửi.
- Bấm vào: xem chi tiết + ảnh chứng chỉ, 2 nút **Duyệt** / **Từ chối**.
- Từ chối: hỏi lý do (bắt buộc nhập) → `XacNhanDialog`.

| Thao tác | API |
|---|---|
| Danh sách | `GET /ho-so-tho?trangThai=CHO_DUYET` |
| Duyệt / từ chối | `PATCH /ho-so-tho/:id/duyet` |

---

### 5.4 `tho/viec/`: Việc của thợ *(tuần 12)*

**File:** `ViecCuaToiFragment.java` · `ViecAdapter.java` · `ChiTietViecActivity.java` + layout

**Danh sách việc** (`ViecCuaToiFragment`)
- Mỗi dòng: dịch vụ, địa chỉ / khu vực, thời gian khách muốn, chip trạng thái.
- Việc mới được giao (`CHO_THO_NHAN`) đặt lên đầu.

**Chi tiết việc** (`ChiTietViecActivity`): mô tả, ảnh khách gửi, địa chỉ, thời gian. Nút thay đổi theo trạng thái:

| Trạng thái hiện tại | Nút hiện ra | API |
|---|---|---|
| Phân công `CHO_THO_NHAN` | **Nhận việc** (chọn giờ dự kiến tới) / **Từ chối** | `PATCH /phan-cong/:id/nhan` |
| Đơn `DA_NHAN` | **Gửi báo giá** (mở `tho/baogia/`) · **Bắt đầu làm** | `PATCH /yeu-cau/:id/trang-thai` → `DANG_LAM` |
| Đơn `DANG_LAM` | Chờ khách xác nhận hoàn tất và thanh toán trên app Flutter | |
| `HOAN_TAT` / `HUY` | Không có nút | |

| Thao tác | API |
|---|---|
| Danh sách | `GET /tho/toi/viec` |
| Chi tiết | `GET /yeu-cau/:id` |

Lỗi phải xử lý: `409` khi đơn đã bị khách hủy giữa chừng → hiện `loi`, tải lại chi tiết.

---

### 5.5 `admin/phanviec/`: Bàn phân việc + tìm thợ phù hợp *(tuần 13, **điểm nhấn ②**)*

**File:** `BanPhanViecFragment.java` · `YeuCauAdapter.java` · `ChiTietYeuCauActivity.java` · `ThoPhuHopAdapter.java` + layout

**Bàn phân việc** (`BanPhanViecFragment`)
- Bộ lọc: trạng thái + khu vực (2 Spinner hoặc chip).
- Mỗi dòng: dịch vụ, khu vực, thời gian khách muốn, chip trạng thái, tên thợ (nếu đã gán).
- Phân trang khi cuộn tới cuối.

**Chi tiết yêu cầu** (`ChiTietYeuCauActivity`)
- Thông tin yêu cầu + ảnh.
- Mục **"Thợ phù hợp"**: danh sách thợ đúng nghề, đúng khu vực, **sắp theo số sao**. Mỗi dòng: tên, số sao, số việc đã làm.
- Bấm một thợ → `XacNhanDialog` "Giao việc cho Nguyễn Văn B?" → gán.

| Thao tác | API |
|---|---|
| Danh sách | `GET /yeu-cau?trangThai=&khuVuc=` |
| Thợ phù hợp | `GET /yeu-cau/:id/tho-phu-hop` |
| Gán thợ | `PATCH /yeu-cau/:id/phan-cong` |

Việc lọc và sắp xếp thợ do **server** làm. App chỉ hiện đúng thứ tự server trả về, **không** tự sắp xếp lại. Khi bảo vệ, nhóm phải chỉ ra được phần này nằm ở backend.

---

### 5.6 `tho/baogia/`: Thợ gửi báo giá *(tuần 13, **điểm nhấn ①**)*

**File:** `TaoBaoGiaActivity.java` · `DongBaoGiaAdapter.java` · `activity_tao_bao_gia.xml` · `item_dong_bao_gia.xml`

- Thợ thêm nhiều dòng. Mỗi dòng: hạng mục, số lượng, đơn giá.
- Khi chọn hạng mục, hiện **giá tham chiếu** bên dưới cho thợ thấy: "Giá tham chiếu: 80.000 – 150.000 đ".
- Cuối màn: **tổng tiền** cộng từ các dòng.
- Bấm **Gửi** → `POST /bao-gia-chi-tiet`.
- Server trả về từng dòng, dòng nào **vượt trần** thì có dấu riêng. App tô dòng đó (chữ đỏ + "Vượt giá trần, chờ quản trị xem xét").

Kiểm tra trên app: số lượng > 0, đơn giá > 0, ít nhất 1 dòng. **App không chặn** đơn giá vượt trần, vì quyết định vượt trần hay không là của **server**. App chỉ cảnh báo trước cho thợ.

Còn **[CẦN CHỐT]** trong `api.md`: mỗi dòng báo giá liên kết tới dịch vụ nào để so giá trần. Chờ chốt rồi mới làm phần chọn hạng mục.

---

### 5.7 `admin/baogia/`: Báo giá vượt trần *(tuần 13, **điểm nhấn ①**)*

**File:** `BaoGiaVuotTranFragment.java` · `BaoGiaVuotTranAdapter.java` + layout

- Danh sách các dòng báo giá vượt trần **chưa xem xét**.
- Mỗi dòng: thợ, yêu cầu, hạng mục, **giá thợ đưa** so với **giá trần**, chênh lệch (ví dụ "+30.000 đ, vượt 20%").
- Bấm **Đã xem xét** → `XacNhanDialog` → `PATCH /bao-gia-chi-tiet/:id/xem-xet` → dòng biến khỏi danh sách.

| Thao tác | API |
|---|---|
| Danh sách | `GET /bao-gia-chi-tiet?vuotTran=true&daXemXet=false` |
| Đánh dấu | `PATCH /bao-gia-chi-tiet/:id/xem-xet` |

---

### 5.8 `admin/khieunai/`: Khiếu nại *(tuần 14)*

**File:** `KhieuNaiFragment.java` · `KhieuNaiAdapter.java` · `ChiTietKhieuNaiActivity.java` + layout

- Lọc: Mới / Đang xử lý / Đã xử lý.
- Mỗi dòng: khách, yêu cầu liên quan, nội dung ngắn, ngày gửi.
- Chi tiết: nội dung đầy đủ, ô nhập **quyết định xử lý** (bắt buộc) → Lưu.

| Thao tác | API |
|---|---|
| Danh sách | `GET /khieu-nai?trangThai=` |
| Ghi quyết định | `PATCH /khieu-nai/:id/quyet-dinh` |

---

## 6. Yêu cầu bắt buộc của môn (phần Android)

Giảng viên chấm theo danh sách này:

| Yêu cầu | Ai | Ở đâu |
|---|---|---|
| Đăng nhập + phân quyền ≥ 2 vai trò | **Thông** (Login) + Tuấn (Splash, 2 MainActivity) | `auth/`, `DieuHuong` |
| ≥ 2 danh sách dùng RecyclerView | **Thông** | Danh mục, dịch vụ, bàn phân việc, việc của thợ, ... |
| Fragment hoặc nhiều Activity | Tuấn + **Thông** | |
| Form có kiểm tra hợp lệ đầy đủ | **Thông** | `DichVuFormActivity`, `TaoBaoGiaActivity` |
| Hộp xác nhận trước khi xóa | **Thông** | Xóa danh mục, xóa dịch vụ |
| ≥ 1 màn hình báo cáo có biểu đồ | Tuấn | `baocao/` |
| Đủ 3 trạng thái: đang tải / xong / lỗi mạng | **Mọi màn hình** | Dùng `StateView` |

### Tự kiểm trước khi mở PR

- [ ] Tắt mạng rồi mở màn hình: hiện lỗi + nút **Thử lại**, app không bị crash.
- [ ] Danh sách rỗng: hiện "Chưa có dữ liệu", không để màn trắng.
- [ ] Xoay màn hình hoặc bấm Back giữa lúc đang tải: app không crash.
- [ ] Form: thử bỏ trống, nhập chữ vào ô số, giá trần < giá sàn → báo đúng ô.
- [ ] Bấm nút Lưu / Gửi 2 lần liên tục: chỉ tạo 1 bản ghi.
- [ ] Không còn dữ liệu giả trong code khi API thật đã có.
- [ ] Không gõ tay chuỗi trạng thái, dùng `HangSo`.

---

## 7. Lịch của Thông

| Tuần | Việc | Mục |
|---|---|---|
| 9–10 | Chuyển bàn phân việc từ nhánh cũ vào khung (theo hướng dẫn Tuấn gửi), rồi Đăng nhập | 5.5, 5.0 |
| 10 | Danh mục + dịch vụ + form + xóa. Chưa có API thì dùng dữ liệu giả trước | 5.1 |
| **11** | **Mốc kiểm tra (không nộp bù):** đăng nhập + màn danh mục chạy bằng **API thật** | 5.0, 5.1 |
| 12 | Hồ sơ thợ, duyệt hồ sơ, việc của thợ | 5.2, 5.3, 5.4 |
| 13 | Bàn phân việc + thợ phù hợp, báo giá thợ, báo giá vượt trần | 5.5, 5.6, 5.7 |
| 14 | Khiếu nại, chạy lại danh sách tự kiểm ở mọi màn hình | 5.8, 6 |
| 15 | Bảo vệ: tự giải thích được code mình đã commit | |

Những mục `api.md` còn ghi **[CẦN CHỐT]** có thể đổi. Trước khi làm màn nào, xem lại `api.md` bản mới nhất.

---

## 8. Git: cách làm và commit

Điểm cá nhân = điểm nhóm × hệ số **tính theo lịch sử commit**. Không có commit thì hệ số là 0.

**Cài 1 lần trên máy:**
```
git config --global user.name  "Nguyễn Hoàng Thông"
git config --global user.email "<email đăng ký GitHub>"
```
Email phải đúng email của tài khoản GitHub. Sai email thì commit không được tính là của mình.

**Mỗi lần làm một tính năng:**
```
git checkout admin-android
git pull
git checkout -b android-danh-muc          # tên nhánh: android-<tính năng>
# ... code, commit nhiều lần ...
git push -u origin android-danh-muc
```

Tên nhánh cho từng mục: `android-danh-muc`, `android-ho-so-tho`, `android-duyet-ho-so`, `android-viec-tho`, `android-phan-viec`, `android-bao-gia-tho`, `android-bao-gia-vuot-tran`, `android-khieu-nai`.

Lên GitHub mở **Pull Request vào nhánh `admin-android`** (không phải `main`), chờ Tuấn xem qua rồi tự merge. Khi merge chọn **Create a merge commit**. **Không chọn Squash and merge**, vì Squash gộp hết commit thành 1.

Trước khi bắt đầu nhánh mới, luôn `git checkout admin-android` rồi `git pull` để lấy code mới nhất của cả nhóm.

**Commit thế nào cho đúng:**
- Ít nhất **15 commit có ý nghĩa**, rải đều các tuần. Không dồn cả tuần vào 1 commit.
- Mỗi commit một việc, viết rõ đã làm gì:
  - ✅ `Them danh sach dich vu bang RecyclerView`
  - ✅ `Kiem tra gia tran khong nho hon gia san trong form`
  - ✅ `Hien thong bao loi khi xoa danh muc con dich vu`
  - ❌ `update`, `fix`, `abc`, `final`
- Ví dụ mục 5.1 có thể tách thành 6–8 commit: layout danh sách → adapter → gọi API → thêm → sửa → xóa có xác nhận → form + kiểm tra → xử lý lỗi 409.
- Khi bảo vệ, thầy sẽ mở commit của mình và hỏi về đoạn code đó. Code mình commit thì mình phải hiểu và giải thích được.

---

## 9. Khi bị kẹt

| Vấn đề | Hỏi ai |
|---|---|
| API trả lỗi lạ, thiếu trường, sai dữ liệu | Tâm (backend), sau đó Tuấn |
| Cần sửa file dùng chung, thêm thư viện, thêm Activity | Tuấn |
| Không biết màn hình nên hiện gì | Đọc lại mục 5, rồi hỏi Tuấn |
| Gradle sync lỗi, merge bị xung đột | Tuấn |

Đừng ngồi kẹt quá nửa buổi một mình. Hỏi sớm thì đỡ trễ tiến độ.
