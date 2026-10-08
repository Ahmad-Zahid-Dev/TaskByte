import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_helper.dart';
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

  List<TaskModel> _tasksForDay(List<TaskModel> all, DateTime day) {
    final norm = DateTime(day.year, day.month, day.day);
    return all.where((t) {
      final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return d == norm;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<TaskProvider>().tasks;
    final selectedTasks = _tasksForDay(all, _selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _MonthHeader(
              month: _monthStart,
              onPrev: _prevMonth,
              onNext: _nextMonth,
            ),
            _MonthGrid(
              monthStart: _monthStart,
              selectedDate: _selectedDate,
              allTasks: all,
              onSelect: (d) => setState(() => _selectedDate = d),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    DateHelper.format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (selectedTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${selectedTasks.length}',
                        style: const TextStyle(
                          fontSize: 11,
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
                  ? const EmptyState(
                      title: 'No tasks',
                      subtitle: 'Nothing scheduled for this day.',
                      icon: Icons.event_available_rounded,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 80),
                      itemCount: selectedTasks.length,
                      itemBuilder: (ctx, i) {
                        final task = selectedTasks[i];
                        final prov = ctx.read<TaskProvider>();
                        return TaskTile(
                          task: task,
                          onToggle: () => prov.toggleComplete(task.id),
                          onTap: () =>
                              context.push(AppRoutes.editTask, extra: task),
                          onDelete: () => prov.deleteTask(task.id),
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
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrev,
            color: AppColors.textPrimary,
          ),
          Text(
            '${_months[month.month - 1]} ${month.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNext,
            color: AppColors.textPrimary,
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

  bool _hasTasks(DateTime day) =>
      allTasks.any((t) => _isSameDay(t.dueDate, day));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final startWeekday = monthStart.weekday % 7; // 0=Sun

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
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
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
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
              final hasTasks = _hasTasks(day);

              return GestureDetector(
                onTap: () => onSelect(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (hasTasks)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
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
