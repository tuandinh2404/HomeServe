import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_request.dart';
import '../../providers/data_providers.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/status_chip.dart';
import 'payment_screen.dart';
import 'rating_screen.dart';
import 'complaint_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});
  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  ServiceRequest? _r;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _r = await ApiService.requestDetail(widget.requestId);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _simulate() async {
    await ApiService.simulateProgress(widget.requestId);
    await _load();
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy yêu cầu?'),
        content: const Text('Bạn có chắc muốn hủy yêu cầu này? Thao tác không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<RequestProvider>().cancel(widget.requestId);
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _r == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(_error ?? 'Lỗi')));
    final r = _r!;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: Text('Yêu cầu #${r.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), boxShadow: [AppTheme.cardShadow]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(r.tenDichVu ?? 'Dịch vụ', style: Theme.of(context).textTheme.titleLarge)),
                      StatusChip(status: r.trangThai),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Mã đơn #${r.id}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 14),
                  _infoRow(Icons.description_outlined, 'Mô tả', r.moTa),
                  _infoRow(Icons.location_on_outlined, 'Địa chỉ', r.diaChi),
                  _infoRow(Icons.map_outlined, 'Khu vực', r.khuVuc),
                  if (r.thoiGianMongMuon != null) _infoRow(Icons.schedule_rounded, 'Thời gian mong muốn', r.thoiGianMongMuon!),
                  if (r.thoiGianDuKienToi != null) _infoRow(Icons.access_time_rounded, 'Thợ dự kiến tới', r.thoiGianDuKienToi!),
                ],
              ),
            ),
            if (r.tho != null) ...[
              const SizedBox(height: 16),
              _workerCard(r.tho!),
            ],
            const SizedBox(height: 16),
            _timeline(r.trangThai),
            const SizedBox(height: 20),
            if (r.trangThai == 'CHO_NHAN' || r.trangThai == 'DA_NHAN') ...[
              ElevatedButton.icon(
                onPressed: _simulate,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Mô phỏng thợ nhận việc (demo)'),
              ),
              const SizedBox(height: 10),
              if (r.trangThai != 'DANG_LAM')
                OutlinedButton(
                  onPressed: _cancel,
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger, side: const BorderSide(color: AppTheme.danger)),
                  child: const Text('Hủy yêu cầu'),
                ),
            ],
            if (r.trangThai == 'DA_NHAN' || r.trangThai == 'DANG_LAM') ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentScreen(requestId: r.id))),
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Xác nhận hoàn tất & thanh toán'),
              ),
            ],
            if (r.trangThai == 'HOAN_TAT') ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RatingScreen(requestId: r.id, workerId: r.tho?.id ?? 0))),
                icon: const Icon(Icons.star_rounded),
                label: const Text('Đánh giá thợ'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintScreen(requestId: r.id))),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Gửi khiếu nại'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.muted),
            const SizedBox(width: 10),
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: AppTheme.muted, fontSize: 13))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
          ],
        ),
      );

  Widget _workerCard(WorkerSummary w) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), boxShadow: [AppTheme.cardShadow]),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.hoTen, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 2),
                    Text(w.diemTb.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('${w.soViecDaLam} việc đã làm', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (w.khuVuc != null) Text(w.khuVuc!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(String status) {
    final steps = ['CHO_NHAN', 'DA_NHAN', 'DANG_LAM', 'HOAN_TAT'];
    final idx = status == 'HUY' ? -1 : steps.indexOf(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), boxShadow: [AppTheme.cardShadow]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiến trình', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length, (i) {
              final done = idx >= i && status != 'HUY';
              final active = idx == i;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: done ? AppTheme.headerGradient : null,
                        color: done ? null : AppTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.statusLabel(steps[i]),
                      style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: done ? AppTheme.primary : AppTheme.muted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
          if (status == 'HUY')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: const [
                  Icon(Icons.cancel_rounded, size: 16, color: AppTheme.danger),
                  SizedBox(width: 6),
                  Text('Đơn đã bị hủy', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}