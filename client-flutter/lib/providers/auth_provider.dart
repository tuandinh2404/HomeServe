import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = true;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> init() async {
    try {
      final token = await StorageService.getToken();
      ApiService.token = token;
      if (token != null) {
        _user = await ApiService.me();
        // Token hết hạn hoặc không hợp lệ (server trả 401) → xóa để về màn đăng nhập
        if (_user == null) {
          ApiService.token = null;
          await StorageService.clearToken();
        }
      }
    } catch (_) {
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String matKhau) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final u = await ApiService.login(email, matKhau);
      // App này chỉ dành cho khách hàng; thợ và quản trị dùng app Android
      if (u.vaiTro != 'KHACH') {
        ApiService.token = null;
        throw Exception('Tài khoản này dùng app Android (thợ / quản trị)');
      }
      // ApiService.login đã gán token THẬT của server vào ApiService.token → lưu lại
      await StorageService.saveToken(ApiService.token!);
      await StorageService.saveUser(u.toJson().toString());
      _user = u;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String matKhau, String hoTen, String sdt) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await ApiService.register(email, matKhau, hoTen, sdt);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
    // Server không trả token khi đăng ký → đăng nhập luôn bằng tài khoản vừa tạo
    return login(email, matKhau);
  }

  Future<void> logout() async {
    _user = null;
    ApiService.token = null;
    await StorageService.clearToken();
    notifyListeners();
  }
}