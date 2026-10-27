class AppConstants {
  static const String appName = 'HomeServe';
  static const String apiBaseUrl = 'http://10.0.2.2:3000'; // Android emulator -> localhost
  static const String tokenKey = 'homeserve_token';
  static const String userKey = 'homeserve_user';

  // Trạng thái yêu cầu
  static const String stChoNhan = 'CHO_NHAN';
  static const String stDaNhan = 'DA_NHAN';
  static const String stDangLam = 'DANG_LAM';
  static const String stHoanTat = 'HOAN_TAT';
  static const String stHuy = 'HUY';

  static String statusLabel(String s) {
    switch (s) {
      case stChoNhan:
        return 'Chờ nhận';
      case stDaNhan:
        return 'Đã nhận';
      case stDangLam:
        return 'Đang làm';
      case stHoanTat:
        return 'Hoàn tất';
      case stHuy:
        return 'Đã hủy';
      default:
        return s;
    }
  }
}