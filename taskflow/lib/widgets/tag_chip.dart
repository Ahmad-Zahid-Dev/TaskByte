import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  static Color _colorFor(String label) => switch (label) {
    'Work' => AppColors.orange,
    'App' => AppColors.primary,
    'Study' => AppColors.primaryLight,
    _ => AppColors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final c = color ?? _colorFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}
