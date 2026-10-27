import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/empty_state.dart';
import '../services/service_list_screen.dart';
import '../services/service_detail_screen.dart';
import '../requests/my_requests_screen.dart';
import '../requests/create_request_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadCategories();
      context.read<ServiceProvider>().loadServices();
      context.read<RequestProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const MyRequestsScreen(embedded: true),
      const ProfileScreen(embedded: true),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Đơn của tôi'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Cá nhân'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateRequestScreen())),
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Đặt dịch vụ'),
            )
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    final auth = context.watch<AuthProvider>();
    return RefreshIndicator(
      onRefresh: () async {
        await sp.loadCategories();
        await sp.loadServices();
      },
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(auth: auth)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: const Text('Danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text)),
            ),
          ),
          if (sp.loading && sp.categories.isEmpty)
            const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())))
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 118,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: sp.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final c = sp.categories[i];
                    final icons = [Icons.bolt_rounded, Icons.water_drop_rounded, Icons.ac_unit_rounded, Icons.kitchen_rounded, Icons.format_paint_rounded];
                    final ic = icons[i % icons.length];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceListScreen(category: c))),
                      child: Container(
                        width: 92,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          boxShadow: [AppTheme.softShadow],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(ic, color: AppTheme.primary, size: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(c.ten, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text), textAlign: TextAlign.center),
                            Text('${c.soDichVu} dịch vụ', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text('Dịch vụ phổ biến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text)),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServiceListScreen())), child: const Text('Xem tất cả')),
                ],
              ),
            ),
          ),
          if (sp.services.isEmpty && !sp.loading)
            const SliverToBoxAdapter(child: EmptyState(title: 'Chưa có dịch vụ', icon: Icons.search_off_rounded))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ServiceCard(
                    service: sp.services[i],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: sp.services[i].id))),
                  ),
                  childCount: sp.services.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AuthProvider auth;
  const _Header({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào 👋', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(auth.user?.hoTen ?? 'bạn', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [AppTheme.softShadow],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm dịch vụ sửa chữa...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.muted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}