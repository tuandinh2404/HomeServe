import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceCategory> categories = [];
  List<Service> services = [];
  bool loading = false;
  String? error;

  Future<void> loadCategories() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      categories = await ApiService.categories();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices({int? danhMucId}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      services = await ApiService.services(danhMucId: danhMucId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class RequestProvider extends ChangeNotifier {
  List<ServiceRequest> requests = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      requests = await ApiService.myRequests();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ServiceRequest> create({
    required int dichVuId,
    required String moTa,
    required String diaChi,
    required String khuVuc,
    double? lat,
    double? lng,
    String? thoiGianMongMuon,
  }) async {
    final r = await ApiService.createRequest(
      dichVuId: dichVuId,
      moTa: moTa,
      diaChi: diaChi,
      khuVuc: khuVuc,
      lat: lat,
      lng: lng,
      thoiGianMongMuon: thoiGianMongMuon,
    );
    requests.insert(0, r);
    notifyListeners();
    return r;
  }

  Future<void> cancel(int id) async {
    await ApiService.cancelRequest(id);
    final idx = requests.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final r = requests[idx];
      requests[idx] = ServiceRequest(
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
        trangThai: 'HUY',
        tho: r.tho,
        thoiGianDuKienToi: r.thoiGianDuKienToi,
        createdAt: r.createdAt,
      );
      notifyListeners();
    }
  }
}