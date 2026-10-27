import 'package:homeserve_flutter/utils/constants.dart';

class WorkerSummary {
  final int id;
  final String hoTen;
  final String? anhDaiDien;
  final double diemTb;
  final int soViecDaLam;
  final String? khuVuc;
  WorkerSummary({
    required this.id,
    required this.hoTen,
    this.anhDaiDien,
    this.diemTb = 0,
    this.soViecDaLam = 0,
    this.khuVuc,
  });
  factory WorkerSummary.fromJson(Map<String, dynamic> j) => WorkerSummary(
        id: (j['id'] as num).toInt(),
        hoTen: j['ho_ten'] ?? j['hoTen'] ?? '',
        anhDaiDien: j['anh_dai_dien'] ?? j['anhDaiDien'],
        diemTb: (j['diem_tb'] ?? j['diemTb'] ?? 0).toDouble(),
        soViecDaLam: (j['so_viec_da_lam'] ?? j['soViecDaLam'] ?? 0) as int,
        khuVuc: j['khu_vuc'] ?? j['khuVuc'],
      );
}

class ServiceRequest {
  final int id;
  final int khachId;
  final int? dichVuId;
  final String? tenDichVu;
  final String moTa;
  final List<String> hinhAnh;
  final String diaChi;
  final String khuVuc;
  final double? lat;
  final double? lng;
  final String? thoiGianMongMuon;
  final String trangThai;
  final int? thoId;
  final WorkerSummary? tho;
  final String? thoiGianDuKienToi;
  final DateTime? createdAt;

  ServiceRequest({
    required this.id,
    required this.khachId,
    this.dichVuId,
    this.tenDichVu,
    required this.moTa,
    this.hinhAnh = const [],
    required this.diaChi,
    required this.khuVuc,
    this.lat,
    this.lng,
    this.thoiGianMongMuon,
    required this.trangThai,
    this.thoId,
    this.tho,
    this.thoiGianDuKienToi,
    this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
        id: (j['id'] as num).toInt(),
        khachId: (j['khach_id'] ?? j['khachId'] ?? 0) as int,
        dichVuId: (j['dich_vu_id'] ?? j['dichVuId']) as int?,
        tenDichVu: j['ten_dich_vu'] ?? j['tenDichVu'],
        moTa: j['mo_ta'] ?? j['moTa'] ?? '',
        hinhAnh: (j['hinh_anh'] ?? j['hinhAnh'] ?? []) is List
            ? List<String>.from(j['hinh_anh'] ?? j['hinhAnh'] ?? [])
            : [],
        diaChi: j['dia_chi'] ?? j['diaChi'] ?? '',
        khuVuc: j['khu_vuc'] ?? j['khuVuc'] ?? '',
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        thoiGianMongMuon: j['thoi_gian_mong_muon'] ?? j['thoiGianMongMuon'],
        trangThai: j['trang_thai'] ?? j['trangThai'] ?? AppConstants.stChoNhan,
        thoId: (j['tho_id'] ?? j['thoId']) as int?,
        tho: (j['tho'] is Map) ? WorkerSummary.fromJson(j['tho']) : null,
        thoiGianDuKienToi: j['thoi_gian_du_kien_toi'] ?? j['thoiGianDuKienToi'],
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
      );

  String get statusLabel => AppConstants.statusLabel(trangThai);
}