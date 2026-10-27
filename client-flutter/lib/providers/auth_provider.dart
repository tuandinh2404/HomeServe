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
      _user = u;
      // mock token
      await StorageService.saveToken('mock-token');
      ApiService.token = 'mock-token';
      await StorageService.saveUser(u.toJson().toString());
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
      final u = await ApiService.register(email, matKhau, hoTen, sdt);
      _user = u;
      await StorageService.saveToken('mock-token');
      ApiService.token = 'mock-token';
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

  Future<void> logout() async {
    _user = null;
    ApiService.token = null;
    await StorageService.clearToken();
    notifyListeners();
  }
}