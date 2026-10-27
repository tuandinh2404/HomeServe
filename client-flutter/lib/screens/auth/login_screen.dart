import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: h - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.home_repair_service_rounded, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('HomeServe', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Đặt dịch vụ sửa chữa tại nhà', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chào mừng trở lại', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text)),
                            const SizedBox(height: 4),
                            const Text('Đăng nhập để tiếp tục', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                              validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _pass,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.muted),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 10),
                              Text(auth.error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                            ],
                            const SizedBox(height: 22),
                            ElevatedButton(
                              onPressed: auth.loading
                                  ? null
                                  : () async {
                                      if (!_form.currentState!.validate()) return;
                                      final ok = await context.read<AuthProvider>().login(_email.text.trim(), _pass.text);
                                      if (ok && context.mounted) {
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                                      }
                                    },
                              child: auth.loading
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                                  : const Text('Đăng nhập'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.text2)),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                  child: const Text('Đăng ký ngay', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.muted),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Tài khoản mẫu: khach1@gmail.com / 123456', style: TextStyle(color: AppTheme.muted, fontSize: 12))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}