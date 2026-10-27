// Dữ liệu mẫu dùng khi backend chưa sẵn sàng.
import '../models/service.dart';
import '../models/service_request.dart';
import '../models/user.dart';

class MockData {
  static final categories = [
    ServiceCategory(id: 1, ten: 'Điện', soDichVu: 5),
    ServiceCategory(id: 2, ten: 'Nước', soDichVu: 4),
    ServiceCategory(id: 3, ten: 'Điều hòa', soDichVu: 3),
    ServiceCategory(id: 4, ten: 'Gia dụng', soDichVu: 6),
    ServiceCategory(id: 5, ten: 'Sơn / sửa nhà', soDichVu: 4),
  ];

  static final services = [
    Service(id: 12, danhMucId: 1, ten: 'Thay ổ cắm', moTa: 'Gồm tháo ổ cũ, lắp ổ mới', giaSan: 80000, giaTran: 150000, donVi: 'cái'),
    Service(id: 13, danhMucId: 1, ten: 'Sửa aptomat', moTa: 'Kiểm tra và thay aptomat', giaSan: 120000, giaTran: 300000, donVi: 'lần'),
    Service(id: 14, danhMucId: 1, ten: 'Lắp đèn mới', moTa: 'Lắp đèn LED/đèn trang trí', giaSan: 60000, giaTran: 200000, donVi: 'bóng'),
    Service(id: 21, danhMucId: 2, ten: 'Sửa vòi nước', moTa: 'Thay gioăng, van vòi', giaSan: 70000, giaTran: 180000, donVi: 'lần'),
    Service(id: 22, danhMucId: 2, ten: 'Thông cống', moTa: 'Thông tắc cống thoát', giaSan: 150000, giaTran: 400000, donVi: 'lần'),
    Service(id: 31, danhMucId: 3, ten: 'Vệ sinh máy lạnh', moTa: 'Vệ sinh dàn nóng/lạnh', giaSan: 150000, giaTran: 350000, donVi: 'máy'),
    Service(id: 32, danhMucId: 3, ten: 'Nạp gas điều hòa', moTa: 'Nạp gas R32/R410A', giaSan: 200000, giaTran: 500000, donVi: 'máy'),
    Service(id: 41, danhMucId: 4, ten: 'Sửa máy giặt', moTa: 'Kiểm tra, sửa lỗi máy giặt', giaSan: 120000, giaTran: 400000, donVi: 'lần'),
    Service(id: 42, danhMucId: 4, ten: 'Sửa tủ lạnh', moTa: 'Kiểm tra block, gas', giaSan: 150000, giaTran: 600000, donVi: 'lần'),
  ];

  static final workers = [
    WorkerSummary(id: 101, hoTen: 'Trần Văn Thợ', anhDaiDien: null, diemTb: 4.8, soViecDaLam: 120, khuVuc: 'Hà Nội'),
    WorkerSummary(id: 102, hoTen: 'Lê Minh Sửa', anhDaiDien: null, diemTb: 4.5, soViecDaLam: 86, khuVuc: 'Hà Nội'),
    WorkerSummary(id: 103, hoTen: 'Phạm Quốc Điện', anhDaiDien: null, diemTb: 4.9, soViecDaLam: 210, khuVuc: 'Hà Nội'),
  ];

  static final demoUser = User(
    id: 7,
    email: 'khach1@gmail.com',
    hoTen: 'Nguyễn Văn A',
    sdt: '0901234567',
    vaiTro: 'KHACH',
  );
}