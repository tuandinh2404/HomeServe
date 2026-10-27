import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final int requestId;
  const PaymentScreen({super.key, required this.requestId});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'TienMat';
  bool _processing = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), boxShadow: [AppTheme.cardShadow]),
              child: Column(
                children: [
                  _row('Tổng tiền dịch vụ', '350.000 đ', bold: false),
                  const SizedBox(height: 8),
                  _row('Hoa hồng (10%)', '35.000 đ'),
                  const Divider(height: 20),
                  _row('Thợ nhận', '315.000 đ', bold: true, color: AppTheme.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Phương thức thanh toán', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text)),
            const SizedBox(height: 10),
            _methodTile('TienMat', 'Tiền mặt', Icons.payments_outlined),
            _methodTile('ChuyenKhoan', 'Chuyển khoản', Icons.account_balance_outlined),
            _methodTile('ViDienTu', 'Ví điện tử', Icons.wallet_outlined),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _processing ? null : _pay,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: _processing
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : const Text('Xác nhận thanh toán'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool bold = false, Color? color}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: bold ? AppTheme.text : AppTheme.text2, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          Text(v, style: TextStyle(fontWeight: FontWeight.w700, color: color ?? AppTheme.text)),
        ],
      );

  Widget _methodTile(String value, String label, IconData icon) {
    final selected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.primary : AppTheme.muted),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500))),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}