import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../requests/create_request_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Future<Service> _future;
  @override
  void initState() {
    super.initState();
    _future = ApiService.serviceDetail(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'vi_VN');
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FutureBuilder<Service>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          final s = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(s.ten, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  background: Container(
                    decoration: BoxDecoration(gradient: AppTheme.headerGradient),
                    child: Center(child: Icon(Icons.handyman_rounded, size: 72, color: Colors.white.withValues(alpha: 0.3))),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.danhMucTen != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(s.danhMucTen!, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      const SizedBox(height: 12),
                      Text(s.moTa ?? '', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), boxShadow: [AppTheme.cardShadow]),
                        child: Column(
                          children: [
                            _row('Giá sàn', '${fmt.format(s.giaSan)} đ', Icons.arrow_downward_rounded, AppTheme.success),
                            const Divider(height: 1),
                            _row('Giá trần', '${fmt.format(s.giaTran)} đ', Icons.arrow_upward_rounded, AppTheme.danger),
                            const Divider(height: 1),
                            _row('Đơn vị tính', s.donVi, Icons.straighten_rounded, AppTheme.muted),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppTheme.accent, size: 18),
                            SizedBox(width: 10),
                            Expanded(child: Text('Giá thực tế được thợ báo sau khi khảo sát, không vượt quá giá trần.', style: TextStyle(fontSize: 13, color: AppTheme.text2))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateRequestScreen(prefillServiceId: s.id))),
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: const Text('Đặt dịch vụ này'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(k, style: const TextStyle(color: AppTheme.text2, fontSize: 14))),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.text)),
          ],
        ),
      );
}