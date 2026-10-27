import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ComplaintScreen extends StatefulWidget {
  final int requestId;
  const ComplaintScreen({super.key, required this.requestId});
  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _content = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập nội dung khiếu nại')));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi khiếu nại')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Gửi khiếu nại')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.danger.withValues(alpha: 0.2))),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.danger, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('Khiếu nại sẽ được quản trị viên xem xét và phản hồi.', style: TextStyle(fontSize: 13, color: AppTheme.text2))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _content,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Nội dung khiếu nại', hintText: 'Ví dụ: giá vượt bảng giá, thái độ thợ...', alignLabelWithHint: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: _submitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : const Text('Gửi khiếu nại'),
            ),
          ],
        ),
      ),
    );
  }
}