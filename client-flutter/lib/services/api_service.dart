import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../models/service_request.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'mock_data.dart';

/// Lớp truy cập API. Mặc định dùng dữ liệu mẫu (mock) để UI chạy được
/// ngay cả khi backend chưa deploy. Đặt [useMock] = false để gọi backend thật.
class ApiService {
  static bool useMock = true;
  static String baseUrl = AppConstants.apiBaseUrl;
  static String? token;

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ---------- Auth ----------
  static Future<User> login(String email, String matKhau) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (email.isEmpty || matKhau.length < 6) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }
      return MockData.demoUser;
    }
    final res = await http.post(
      Uri.parse('$baseUrl/auth/dang-nhap'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'mat_khau': matKhau}),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
    final j = jsonDecode(res.body);
    token = j['token'];
    return User.fromJson(j['nguoi_dung']);
  }

  static Future<User> register(String email, String matKhau, String hoTen, String sdt) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return User(id: 99, email: email, hoTen: hoTen, sdt: sdt, vaiTro: 'KHACH');
    }
    final res = await http.post(
      Uri.parse('$baseUrl/auth/dang-ky'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'mat_khau': matKhau, 'ho_ten': hoTen, 'sdt': sdt}),
    );
    if (res.statusCode != 201) throw Exception(_err(res));
    return User.fromJson(jsonDecode(res.body));
  }

  static Future<User?> me() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.demoUser;
    }
    if (token == null) return null;
    final res = await http.get(Uri.parse('$baseUrl/auth/toi'), headers: _headers());
    if (res.statusCode != 200) return null;
    return User.fromJson(jsonDecode(res.body));
  }

  // ---------- Danh mục / dịch vụ ----------
  static Future<List<ServiceCategory>> categories() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.categories;
    }
    final res = await http.get(Uri.parse('$baseUrl/danh-muc-dv'));
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ServiceCategory.fromJson(e)).toList();
  }

  static Future<List<Service>> services({int? danhMucId}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (danhMucId == null) return MockData.services;
      return MockData.services.where((s) => s.danhMucId == danhMucId).toList();
    }
    final uri = Uri.parse('$baseUrl/dich-vu').replace(
      queryParameters: danhMucId != null ? {'danhMucId': '$danhMucId'} : null,
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Service.fromJson(e)).toList();
  }

  static Future<Service> serviceDetail(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.services.firstWhere((s) => s.id == id);
    }
    final res = await http.get(Uri.parse('$baseUrl/dich-vu/$id/bang-gia'));
    if (res.statusCode != 200) throw Exception(_err(res));
    return Service.fromJson(jsonDecode(res.body));
  }

  // ---------- Yêu cầu ----------
  static final List<ServiceRequest> _mockRequests = [];
  static int _nextReqId = 1000;

  static Future<ServiceRequest> createRequest({
    required int dichVuId,
    required String moTa,
    required String diaChi,
    required String khuVuc,
    double? lat,
    double? lng,
    String? thoiGianMongMuon,
    List<String> hinhAnh = const [],
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 700));
      final sv = MockData.services.firstWhere((s) => s.id == dichVuId);
      final r = ServiceRequest(
        id: _nextReqId++,
        khachId: MockData.demoUser.id,
        dichVuId: dichVuId,
        tenDichVu: sv.ten,
        moTa: moTa,
        hinhAnh: hinhAnh,
        diaChi: diaChi,
        khuVuc: khuVuc,
        lat: lat,
        lng: lng,
        thoiGianMongMuon: thoiGianMongMuon,
        trangThai: AppConstants.stChoNhan,
        createdAt: DateTime.now(),
      );
      _mockRequests.insert(0, r);
      return r;
    }
    final res = await http.post(
      Uri.parse('$baseUrl/yeu-cau'),
      headers: _headers(),
      body: jsonEncode({
        'dich_vu_id': dichVuId,
        'mo_ta': moTa,
        'dia_chi': diaChi,
        'khu_vuc': khuVuc,
        'lat': lat,
        'lng': lng,
        'thoi_gian_mong_muon': thoiGianMongMuon,
        'hinh_anh': hinhAnh,
      }),
    );
    if (res.statusCode != 201) throw Exception(_err(res));
    return ServiceRequest.fromJson(jsonDecode(res.body));
  }

  static Future<List<ServiceRequest>> myRequests() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return List.of(_mockRequests);
    }
    final res = await http.get(Uri.parse('$baseUrl/yeu-cau/cua-toi'), headers: _headers());
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ServiceRequest.fromJson(e)).toList();
  }

  static Future<ServiceRequest> requestDetail(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockRequests.firstWhere((r) => r.id == id,
          orElse: () => ServiceRequest(
                id: id,
                khachId: MockData.demoUser.id,
                moTa: 'Yêu cầu #$id',
                diaChi: '—',
                khuVuc: '—',
                trangThai: AppConstants.stChoNhan,
              ));
    }
    final res = await http.get(Uri.parse('$baseUrl/yeu-cau/$id'), headers: _headers());
    if (res.statusCode != 200) throw Exception(_err(res));
    return ServiceRequest.fromJson(jsonDecode(res.body));
  }

  static Future<void> cancelRequest(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final idx = _mockRequests.indexWhere((r) => r.id == id);
      if (idx >= 0) {
        final r = _mockRequests[idx];
        _mockRequests[idx] = ServiceRequest(
          id: r.id,
          khachId: r.khachId,
          dichVuId: r.dichVuId,
          tenDichVu: r.tenDichVu,
          moTa: r.moTa,
          hinhAnh: r.hinhAnh,
          diaChi: r.diaChi,
          khuVuc: r.khuVuc,
          lat: r.lat,
          lng: r.lng,
          thoiGianMongMuon: r.thoiGianMongMuon,
          trangThai: AppConstants.stHuy,
          tho: r.tho,
          thoiGianDuKienToi: r.thoiGianDuKienToi,
          createdAt: r.createdAt,
        );
      }
      return;
    }
    final res = await http.patch(Uri.parse('$baseUrl/yeu-cau/$id/huy'), headers: _headers());
    if (res.statusCode != 200) throw Exception(_err(res));
  }

  // Mock: simulate worker assigned + quote after some time
  static Future<void> simulateProgress(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    final idx = _mockRequests.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    final r = _mockRequests[idx];
    _mockRequests[idx] = ServiceRequest(
      id: r.id,
      khachId: r.khachId,
      dichVuId: r.dichVuId,
      tenDichVu: r.tenDichVu,
      moTa: r.moTa,
      hinhAnh: r.hinhAnh,
      diaChi: r.diaChi,
      khuVuc: r.khuVuc,
      lat: r.lat,
      lng: r.lng,
      thoiGianMongMuon: r.thoiGianMongMuon,
      trangThai: AppConstants.stDaNhan,
      tho: MockData.workers.first,
      thoiGianDuKienToi: '30 phút',
      createdAt: r.createdAt,
    );
  }

  static String _err(http.Response res) {
    try {
      final j = jsonDecode(res.body);
      return j['loi'] ?? 'Lỗi ${res.statusCode}';
    } catch (_) {
      return 'Lỗi ${res.statusCode}';
    }
  }
}