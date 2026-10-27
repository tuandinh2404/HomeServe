import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/empty_state.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final ServiceCategory? category;
  const ServiceListScreen({super.key, this.category});
  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices(danhMucId: widget.category?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        foregroundColor: AppTheme.text,
        elevation: 0,
        title: Text(widget.category?.ten ?? 'Tất cả dịch vụ'),
      ),
      body: sp.loading && sp.services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : sp.services.isEmpty
              ? const EmptyState(title: 'Không có dịch vụ', icon: Icons.search_off_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: sp.services.length,
                  itemBuilder: (_, i) => ServiceCard(
                    service: sp.services[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: sp.services[i].id)),
                    ),
                  ),
                ),
    );
  }
}