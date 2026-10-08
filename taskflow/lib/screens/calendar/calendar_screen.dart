import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/empty_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _monthStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthStart = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _monthStart = DateTime(_monthStart.year, _monthStart.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _monthStart = DateTime(_monthStart.year, _monthStart.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _monthStart = DateTime(now.year, now.month, 1);
      _selectedDate = now;
    });
  }

  List<TaskModel> _tasksForDay(List<TaskModel> all, DateTime day) {
    final norm = DateTime(day.year, day.month, day.day);
    return all.where((t) {
      final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return d == norm;
    }).toList();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _monthStart.year == now.year && _monthStart.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<TaskProvider>().tasks;
    final selectedTasks = _tasksForDay(all, _selectedDate);

    final isToday = DateHelper.isToday(_selectedDate);
    final isTomorrow = DateHelper.isTomorrow(_selectedDate);
    final dayLabel = isToday
        ? 'Today'
        : isTomorrow
        ? 'Tomorrow'
        : DateHelper.format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _MonthHeader(
              month: _monthStart,
              onPrev: _prevMonth,
              onNext: _nextMonth,
              onToday: _goToToday,
              showTodayBtn: !_isCurrentMonth,
            ),
            _MonthGrid(
              monthStart: _monthStart,
              selectedDate: _selectedDate,
              allTasks: all,
              onSelect: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Text(
                    dayLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!isToday && !isTomorrow) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${_selectedDate.day}/${_selectedDate.month})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (selectedTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedTasks.length} ${selectedTasks.length == 1 ? 'task' : 'tasks'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: selectedTasks.isEmpty
                  ? Center(
                      child: EmptyState(
                        title: 'No tasks scheduled',
                        subtitle: 'Enjoy your free time or add a task for this day.',
                        icon: Icons.event_available_rounded,
                        ctaLabel: 'Add task for this day',
                        onCtaPressed: () => context.push(AppRoutes.addTask),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 90),
                      itemCount: selectedTasks.length,
                      itemBuilder: (ctx, i) {
                        final task = selectedTasks[i];
                        final prov = ctx.read<TaskProvider>();
                        return TaskTile(
                          task: task,
                          onToggle: () => prov.toggleComplete(task.id),
                          onTap: () =>
                              context.push(AppRoutes.editTask, extra: task),
                          onDelete: () async {
                            await prov.deleteTask(task.id);
                            if (!context.mounted) return;
                            SnackBarHelper.showTaskDeleted(
                              context,
                              onUndo: () => prov.undoDelete(),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.showTodayBtn,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final bool showTodayBtn;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
              onPressed: onPrev,
              color: AppColors.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  '${_months[month.month - 1]} ${month.year}',
                  key: ValueKey('${month.year}-${month.month}'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (showTodayBtn) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              onPressed: onNext,
              color: AppColors.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.monthStart,
    required this.selectedDate,
    required this.allTasks,
    required this.onSelect,
  });

  final DateTime monthStart;
  final DateTime selectedDate;
  final List<TaskModel> allTasks;
  final ValueChanged<DateTime> onSelect;

  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<TaskModel> _tasksForDay(DateTime day) {
    final norm = DateTime(day.year, day.month, day.day);
    return allTasks.where((t) {
      final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return d == norm;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final startWeekday = monthStart.weekday % 7; // 0=Sun

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startWeekday) return const SizedBox();
              final day = DateTime(
                monthStart.year,
                monthStart.month,
                index - startWeekday + 1,
              );
              final isSelected = _isSameDay(day, selectedDate);
              final isToday = _isSameDay(day, DateTime.now());
              final tasks = _tasksForDay(day);
              final hasTasks = tasks.isNotEmpty;

              Color indicatorColor = AppColors.primary;
              if (hasTasks) {
                if (tasks.any((t) => t.priority == Priority.high && !t.isCompleted)) {
                  indicatorColor = AppColors.orange;
                } else if (tasks.any((t) => t.priority == Priority.medium && !t.isCompleted)) {
                  indicatorColor = AppColors.amber;
                } else if (tasks.every((t) => t.isCompleted)) {
                  indicatorColor = AppColors.green;
                }
              }

              return GestureDetector(
                onTap: () => onSelect(day),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasTasks)
                        Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : indicatorColor,
                          ),
                        )
                      else
                        const SizedBox(height: 4.5),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
