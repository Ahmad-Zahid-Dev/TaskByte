import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.statusFilter,
    required this.priorityFilter,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final String statusFilter;
  final String priorityFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;

  static const _statuses = ['All', 'Pending', 'Completed'];
  static const _priorities = ['All', 'Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipRow(
          items: _statuses,
          selected: statusFilter,
          onSelect: onStatusChanged,
        ),
        const SizedBox(height: 6),
        _ChipRow(
          items: _priorities,
          selected: priorityFilter,
          onSelect: onPriorityChanged,
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  Color _chipColor(String item) => switch (item) {
    'High' => AppColors.orange,
    'Medium' => AppColors.amber,
    'Low' => AppColors.green,
    'Completed' => AppColors.green,
    'Pending' => AppColors.primary,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items.map((item) {
          final isSelected = item == selected;
          final color = _chipColor(item);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => onSelect(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
