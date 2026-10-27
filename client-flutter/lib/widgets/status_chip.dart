import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool compact;
  const StatusChip({super.key, required this.status, this.compact = false});

  (Color, IconData) _style() {
    switch (status) {
      case 'HOAN_TAT':
        return (AppTheme.success, Icons.check_circle);
      case 'HUY':
        return (AppTheme.danger, Icons.cancel);
      case 'DANG_LAM':
        return (AppTheme.info, Icons.engineering);
      case 'DA_NHAN':
        return (AppTheme.accent, Icons.thumb_up_alt);
      default:
        return (AppTheme.muted, Icons.hourglass_top);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            AppConstants.statusLabel(status),
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: compact ? 11 : 12),
          ),
        ],
      ),
    );
  }
}