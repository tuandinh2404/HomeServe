import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        foregroundColor: AppTheme.text,
        elevation: 0,
        title: const Text('Tạo tài khoản'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tham gia HomeServe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 4),
                const Text('Điền thông tin để bắt đầu đặt dịch vụ', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
                const SizedBox(height: 24),
                _field(_name, 'Họ và tên', Icons.person_outline_rounded, (v) => (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null),
                const SizedBox(height: 14),
                _field(_email, 'Email', Icons.mail_outline_rounded, (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null, type: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _field(_phone, 'Số điện thoại', Icons.phone_outlined, (v) => (v == null || v.length < 9) ? 'SĐT không hợp lệ' : null, type: TextInputType.phone),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.muted), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 10),
                  Text(auth.error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.loading
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) return;
                          final ok = await context.read<AuthProvider>().register(_email.text.trim(), _pass.text, _name.text.trim(), _phone.text.trim());
                          if (ok && context.mounted) {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                          }
                        },
                  child: auth.loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                      : const Text('Tạo tài khoản'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, String? Function(String?) v, {TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: v,
    );
  }
}