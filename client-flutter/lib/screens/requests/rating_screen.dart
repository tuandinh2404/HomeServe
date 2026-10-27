import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  final int requestId;
  final int workerId;
  const RatingScreen({super.key, required this.requestId, required this.workerId});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _comment = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã đánh giá')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Rất tệ', 'Tệ', 'Bình thường', 'Tốt', 'Xuất sắc'];
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Đánh giá')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.person_rounded, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text('Bạn hài lòng với dịch vụ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.text)),
            const SizedBox(height: 6),
            Text(labels[_stars - 1], style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final v = i + 1;
                return IconButton(
                  icon: Icon(v <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 40, color: AppTheme.accent),
                  onPressed: () => setState(() => _stars = v),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _comment,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Nhận xét (tuỳ chọn)', alignLabelWithHint: true),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}