import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_theme.dart';
import 'request_detail_screen.dart';

class CreateRequestScreen extends StatefulWidget {
  final int? prefillServiceId;
  const CreateRequestScreen({super.key, this.prefillServiceId});
  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _addr = TextEditingController();
  final _area = TextEditingController();
  final _time = TextEditingController();
  int? _serviceId;
  final List<String> _images = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.prefillServiceId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x != null) setState(() => _images.add(x.path));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn dịch vụ')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final r = await context.read<RequestProvider>().create(
            dichVuId: _serviceId!,
            moTa: _desc.text.trim(),
            diaChi: _addr.text.trim(),
            khuVuc: _area.text.trim(),
            thoiGianMongMuon: _time.text.trim().isEmpty ? null : _time.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo yêu cầu thành công')));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RequestDetailScreen(requestId: r.id)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    final services = sp.services;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, foregroundColor: AppTheme.text, elevation: 0, title: const Text('Tạo yêu cầu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Thông tin dịch vụ'),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _serviceId,
                decoration: const InputDecoration(labelText: 'Dịch vụ', prefixIcon: Icon(Icons.build_outlined)),
                items: services.map((s) => DropdownMenuItem(value: s.id, child: Text(s.ten))).toList(),
                onChanged: (v) => setState(() => _serviceId = v),
                validator: (v) => v == null ? 'Chọn dịch vụ' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả vấn đề', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().length < 5) ? 'Mô tả ít nhất 5 ký tự' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Địa điểm'),
              const SizedBox(height: 10),
              TextFormField(controller: _addr, decoration: const InputDecoration(labelText: 'Địa chỉ', prefixIcon: Icon(Icons.location_on_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập địa chỉ' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _area, decoration: const InputDecoration(labelText: 'Khu vực (quận/huyện)', prefixIcon: Icon(Icons.map_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập khu vực' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _time, decoration: const InputDecoration(labelText: 'Thời gian mong muốn (tuỳ chọn)', prefixIcon: Icon(Icons.schedule_rounded))),
              const SizedBox(height: 20),
              _sectionTitle('Hình ảnh / video'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                  ),
                  child: _images.isEmpty
                      ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_photo_alternate_outlined, color: AppTheme.muted), SizedBox(height: 4), Text('Thêm ảnh', style: TextStyle(color: AppTheme.muted, fontSize: 13))]))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _images.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            if (i == _images.length) {
                              return Container(width: 80, decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: AppTheme.muted));
                            }
                            return ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 80, color: AppTheme.bg, child: const Icon(Icons.image, color: AppTheme.muted)));
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                    : const Text('Gửi yêu cầu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text));
}