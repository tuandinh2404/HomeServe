import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/empty_state.dart';
import 'request_detail_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  final bool embedded;
  const MyRequestsScreen({super.key, this.embedded = false});
  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  String? _filter;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RequestProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RequestProvider>();
    final list = _filter == null ? rp.requests : rp.requests.where((r) => r.trangThai == _filter).toList();
    final body = Column(
      children: [
        Container(
          color: AppTheme.bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('Tất cả', null, rp.requests.length),
                _chip('Chờ nhận', 'CHO_NHAN', rp.requests.where((r) => r.trangThai == 'CHO_NHAN').length),
                _chip('Đã nhận', 'DA_NHAN', rp.requests.where((r) => r.trangThai == 'DA_NHAN').length),
                _chip('Đang làm', 'DANG_LAM', rp.requests.where((r) => r.trangThai == 'DANG_LAM').length),
                _chip('Hoàn tất', 'HOAN_TAT', rp.requests.where((r) => r.trangThai == 'HOAN_TAT').length),
                _chip('Đã hủy', 'HUY', rp.requests.where((r) => r.trangThai == 'HUY').length),
              ],
            ),
          ),
        ),
        Expanded(
          child: rp.loading && rp.requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? const EmptyState(title: 'Chưa có yêu cầu nào', subtitle: 'Hãy đặt dịch vụ đầu tiên của bạn', icon: Icons.receipt_long_outlined)
                  : RefreshIndicator(
                      onRefresh: () => rp.load(),
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: list.length,
                        itemBuilder: (_, i) => RequestCard(
                          request: list[i],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestDetailScreen(requestId: list[i].id))),
                        ),
                      ),
                    ),
        ),
      ],
    );
    if (widget.embedded) return SafeArea(child: body);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Đơn của tôi')),
      body: body,
    );
  }

  Widget _chip(String label, String? value, int count) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: (selected ? AppTheme.primary : AppTheme.muted).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? AppTheme.primary : AppTheme.muted)),
            ),
          ],
        ),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}