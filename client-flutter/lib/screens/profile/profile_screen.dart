import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: const Icon(Icons.person_rounded, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: Text(user?.hoTen ?? 'Khách', style: Theme.of(context).textTheme.headlineMedium)),
        const SizedBox(height: 2),
        Center(child: Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(height: 24),
        _tile(Icons.phone_rounded, 'Số điện thoại', user?.sdt ?? '—'),
        _tile(Icons.badge_rounded, 'Vai trò', user?.vaiTro ?? '—'),
        _tile(Icons.location_on_outlined, 'Khu vực', 'Hà Nội'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
          child: Row(
            children: [
              const Icon(Icons.storage_rounded, color: AppTheme.primary),
              const SizedBox(width: 12),
              const Expanded(child: Text('Dữ liệu mẫu (mock) đang bật', style: TextStyle(fontWeight: FontWeight.w500))),
              Switch(value: true, onChanged: (_) {}, activeThumbColor: AppTheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
    if (widget.embedded) return SafeArea(child: body);
    return Scaffold(backgroundColor: AppTheme.bg, appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Cá nhân')), body: body);
  }

  Widget _tile(IconData icon, String k, String v) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [AppTheme.softShadow]),
        child: Row(
          children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.primary, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
}