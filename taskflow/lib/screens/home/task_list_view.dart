import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/empty_state.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  static const _groupOrder = [
    TaskGroup.overdue,
    TaskGroup.today,
    TaskGroup.tomorrow,
    TaskGroup.thisWeek,
    TaskGroup.later,
  ];

  static String _groupLabel(TaskGroup g) => switch (g) {
    TaskGroup.overdue => AppStrings.overdue,
    TaskGroup.today => AppStrings.today,
    TaskGroup.tomorrow => AppStrings.tomorrow,
    TaskGroup.thisWeek => AppStrings.thisWeek,
    TaskGroup.later => AppStrings.later,
  };

  @override
  Widget build(BuildContext context) {
    final grouped = context.watch<TaskProvider>().grouped;

    if (grouped.isEmpty) {
      final taskProv = context.read<TaskProvider>();
      final hasFilters =
          taskProv.hasActiveFilters || taskProv.search.isNotEmpty;

      return EmptyState(
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.add_task_rounded,
        title: hasFilters ? AppStrings.noMatches : 'No tasks yet',
        subtitle: hasFilters
            ? AppStrings.noMatchesSub
            : 'You have no tasks scheduled. Tap below to create your first task and get started!',
        ctaLabel: hasFilters ? 'Reset filters' : 'Add your first task',
        onCtaPressed: () {
          if (hasFilters) {
            taskProv.resetFilters();
          } else {
            context.push(AppRoutes.addTask);
          }
        },
      );
    }

    final items = <Widget>[];
    int delay = 0;

    for (final group in _groupOrder) {
      final tasks = grouped[group];
      if (tasks == null || tasks.isEmpty) continue;

      items.add(SectionHeader(title: _groupLabel(group), count: tasks.length));
      for (final task in tasks) {
        items.add(
          _AnimatedTile(task: task, delay: delay)
              .animate()
              .fadeIn(delay: (delay * 40).ms, duration: 300.ms)
              .slideX(begin: 0.08, end: 0),
        );
        delay++;
      }
    }

    items.add(const SizedBox(height: 100));

    return ListView(padding: const EdgeInsets.only(top: 4), children: items);
  }
}

class _AnimatedTile extends StatelessWidget {
  const _AnimatedTile({required this.task, required this.delay});

  final TaskModel task;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TaskProvider>();

    return TaskTile(
      task: task,
      onToggle: () => prov.toggleComplete(task.id),
      onTap: () => context.push(AppRoutes.editTask, extra: task),
      onDelete: () async {
        await prov.deleteTask(task.id);
        if (!context.mounted) return;
        SnackBarHelper.showTaskDeleted(
          context,
          onUndo: () => prov.undoDelete(),
        );
      },
    );
  }
}
