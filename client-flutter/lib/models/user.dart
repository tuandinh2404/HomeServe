class User {
  final int id;
  final String email;
  final String hoTen;
  final String? sdt;
  final String vaiTro;
  final String? anhDaiDien;

  User({
    required this.id,
    required this.email,
    required this.hoTen,
    this.sdt,
    required this.vaiTro,
    this.anhDaiDien,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] as num).toInt(),
        email: j['email'] ?? '',
        hoTen: j['ho_ten'] ?? j['hoTen'] ?? '',
        sdt: j['sdt'],
        vaiTro: j['vai_tro'] ?? j['vaiTro'] ?? 'KHACH',
        anhDaiDien: j['anh_dai_dien'] ?? j['anhDaiDien'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'ho_ten': hoTen,
        'sdt': sdt,
        'vai_tro': vaiTro,
        'anh_dai_dien': anhDaiDien,
      };
}