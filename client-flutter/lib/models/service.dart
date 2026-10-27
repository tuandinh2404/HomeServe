class ServiceCategory {
  final int id;
  final String ten;
  final int soDichVu;
  ServiceCategory({required this.id, required this.ten, this.soDichVu = 0});
  factory ServiceCategory.fromJson(Map<String, dynamic> j) => ServiceCategory(
        id: (j['id'] as num).toInt(),
        ten: j['ten'] ?? '',
        soDichVu: (j['so_dich_vu'] ?? j['soDichVu'] ?? 0) as int,
      );
}

class Service {
  final int id;
  final int danhMucId;
  final String ten;
  final String? moTa;
  final int giaSan;
  final int giaTran;
  final String donVi;
  final String? danhMucTen;

  Service({
    required this.id,
    required this.danhMucId,
    required this.ten,
    this.moTa,
    required this.giaSan,
    required this.giaTran,
    required this.donVi,
    this.danhMucTen,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: (j['id'] as num).toInt(),
        danhMucId: (j['danh_muc_id'] ?? j['danhMucId'] ?? 0) as int,
        ten: j['ten'] ?? '',
        moTa: j['mo_ta'] ?? j['moTa'],
        giaSan: (j['gia_san'] ?? j['giaSan'] ?? 0) as int,
        giaTran: (j['gia_tran'] ?? j['giaTran'] ?? 0) as int,
        donVi: j['don_vi'] ?? j['donVi'] ?? '',
        danhMucTen: (j['danh_muc'] is Map) ? j['danh_muc']['ten'] : j['danhMucTen'],
      );
}