class QuoteLine {
  final int id;
  final String hangMuc;
  final int soLuong;
  final int donGia;
  final bool vuotTran;
  final bool daXemXet;
  QuoteLine({
    required this.id,
    required this.hangMuc,
    required this.soLuong,
    required this.donGia,
    this.vuotTran = false,
    this.daXemXet = false,
  });
  int get thanhTien => soLuong * donGia;
  factory QuoteLine.fromJson(Map<String, dynamic> j) => QuoteLine(
        id: (j['id'] as num).toInt(),
        hangMuc: j['hang_muc'] ?? j['hangMuc'] ?? '',
        soLuong: (j['so_luong'] ?? j['soLuong'] ?? 1) as int,
        donGia: (j['don_gia'] ?? j['donGia'] ?? 0) as int,
        vuotTran: (j['vuot_tran'] ?? j['vuotTran'] ?? false) as bool,
        daXemXet: (j['da_xem_xet'] ?? j['daXemXet'] ?? false) as bool,
      );
}

class Review {
  final int id;
  final int nguoiDanhGiaId;
  final int nguoiDuocDanhGiaId;
  final int soSao;
  final String? nhanXet;
  Review({
    required this.id,
    required this.nguoiDanhGiaId,
    required this.nguoiDuocDanhGiaId,
    required this.soSao,
    this.nhanXet,
  });
  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: (j['id'] as num).toInt(),
        nguoiDanhGiaId: (j['nguoi_danh_gia_id'] ?? j['nguoiDanhGiaId'] ?? 0) as int,
        nguoiDuocDanhGiaId: (j['nguoi_duoc_danh_gia_id'] ?? j['nguoiDuocDanhGiaId'] ?? 0) as int,
        soSao: (j['so_sao'] ?? j['soSao'] ?? 0) as int,
        nhanXet: j['nhan_xet'] ?? j['nhanXet'],
      );
}