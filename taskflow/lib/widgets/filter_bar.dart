import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.statusFilter,
    required this.priorityFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onResetFilters,
  });

  final String statusFilter;
  final String priorityFilter;
  final String categoryFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onResetFilters;

  static const _statuses = ['All', 'Pending', 'Completed'];
  static const _priorities = ['All', 'Low', 'Medium', 'High'];
  static const _categories = ['All', 'Personal', 'Work', 'Study'];

  int get _activeCount {
    int count = 0;
    if (statusFilter != 'All') count++;
    if (priorityFilter != 'All') count++;
    if (categoryFilter != 'All') count++;
    return count;
  }

  void _showAllFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ModernFilterSheet(
        statusFilter: statusFilter,
        priorityFilter: priorityFilter,
        categoryFilter: categoryFilter,
        onStatusChanged: onStatusChanged,
        onPriorityChanged: onPriorityChanged,
        onCategoryChanged: onCategoryChanged,
        onResetFilters: onResetFilters,
      ),
    );
  }

  void _showSingleFilterMenu({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
    Color Function(String)? colorForOption,
    IconData? Function(String)? iconForOption,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select $title',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (selected != 'All')
                  TextButton(
                    onPressed: () {
                      onSelected('All');
                      Navigator.pop(ctx);
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: options.map((opt) {
                final isSelected = opt == selected;
                final optColor = colorForOption?.call(opt) ?? AppColors.primary;
                final optIcon = iconForOption?.call(opt);

                return GestureDetector(
                  onTap: () {
                    onSelected(opt);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? optColor : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? optColor
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: optColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (optIcon != null) ...[
                          Icon(
                            optIcon,
                            size: 15,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 1. Modern Filter Button
          _FilterIconButton(
            activeCount: _activeCount,
            onTap: () => _showAllFiltersSheet(context),
          ),
          const SizedBox(width: 8),

          // 2. Status Pill with proper naming convention
          _FilterPill(
            label: 'Status',
            value: statusFilter,
            isActive: statusFilter != 'All',
            activeColor: statusFilter == 'Completed'
                ? AppColors.green
                : AppColors.primary,
            onTap: () => _showSingleFilterMenu(
              context: context,
              title: 'Status',
              options: _statuses,
              selected: statusFilter,
              onSelected: onStatusChanged,
              colorForOption: (s) =>
                  s == 'Completed' ? AppColors.green : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Priority Pill with proper naming convention
          _FilterPill(
            label: 'Priority',
            value: priorityFilter,
            isActive: priorityFilter != 'All',
            activeColor: switch (priorityFilter) {
              'High' => AppColors.orange,
              'Medium' => AppColors.amber,
              'Low' => AppColors.green,
              _ => AppColors.primary,
            },
            onTap: () => _showSingleFilterMenu(
              context: context,
              title: 'Priority',
              options: _priorities,
              selected: priorityFilter,
              onSelected: onPriorityChanged,
              colorForOption: (p) => switch (p) {
                'High' => AppColors.orange,
                'Medium' => AppColors.amber,
                'Low' => AppColors.green,
                _ => AppColors.primary,
              },
            ),
          ),
          const SizedBox(width: 8),

          // 4. Category Pill with proper naming convention
          _FilterPill(
            label: 'Category',
            value: categoryFilter,
            isActive: categoryFilter != 'All',
            activeColor: AppColors.primary,
            onTap: () => _showSingleFilterMenu(
              context: context,
              title: 'Category',
              options: _categories,
              selected: categoryFilter,
              onSelected: onCategoryChanged,
              iconForOption: (c) => switch (c) {
                'Personal' => Icons.person_outline_rounded,
                'Work' => Icons.work_outline_rounded,
                'Study' => Icons.school_outlined,
                _ => null,
              },
            ),
          ),

          // 5. Quick Reset if active
          if (_activeCount > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onResetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, size: 14, color: AppColors.danger),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasActive = activeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: hasActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasActive
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: hasActive
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: hasActive ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (hasActive) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$activeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.value,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? activeColor
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? activeColor.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernFilterSheet extends StatefulWidget {
  const _ModernFilterSheet({
    required this.statusFilter,
    required this.priorityFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onResetFilters,
  });

  final String statusFilter;
  final String priorityFilter;
  final String categoryFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onResetFilters;

  @override
  State<_ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late String _status;
  late String _priority;
  late String _category;

  @override
  void initState() {
    super.initState();
    _status = widget.statusFilter;
    _priority = widget.priorityFilter;
    _category = widget.categoryFilter;
  }

  void _apply() {
    widget.onStatusChanged(_status);
    widget.onPriorityChanged(_priority);
    widget.onCategoryChanged(_category);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _status = 'All';
      _priority = 'All';
      _category = 'All';
    });
    widget.onResetFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Filter Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset all', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Status Section
            const _SectionTitle('Status'),
            const SizedBox(height: 8),
            _SheetRow(
              options: FilterBar._statuses,
              selected: _status,
              onSelect: (v) => setState(() => _status = v),
              colorForOption: (s) =>
                  s == 'Completed' ? AppColors.green : AppColors.primary,
            ),
            const SizedBox(height: 18),

            // 2. Priority Section
            const _SectionTitle('Priority'),
            const SizedBox(height: 8),
            _SheetRow(
              options: FilterBar._priorities,
              selected: _priority,
              onSelect: (v) => setState(() => _priority = v),
              colorForOption: (p) => switch (p) {
                'High' => AppColors.orange,
                'Medium' => AppColors.amber,
                'Low' => AppColors.green,
                _ => AppColors.primary,
              },
            ),
            const SizedBox(height: 18),

            // 3. Category Section
            const _SectionTitle('Category'),
            const SizedBox(height: 8),
            _SheetRow(
              options: FilterBar._categories,
              selected: _category,
              onSelect: (v) => setState(() => _category = v),
              colorForOption: (_) => AppColors.primary,
              iconForOption: (c) => switch (c) {
                'Personal' => Icons.person_outline_rounded,
                'Work' => Icons.work_outline_rounded,
                'Study' => Icons.school_outlined,
                _ => null,
              },
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.colorForOption,
    this.iconForOption,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color Function(String) colorForOption;
  final IconData? Function(String)? iconForOption;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          final color = colorForOption(opt);
          final icon = iconForOption?.call(opt);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
