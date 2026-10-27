import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(AppConstants.tokenKey);
  }

  static Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(AppConstants.tokenKey);
    await sp.remove(AppConstants.userKey);
  }

  static Future<void> saveUser(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(AppConstants.userKey, json);
  }

  static Future<String?> getUser() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(AppConstants.userKey);
  }
}