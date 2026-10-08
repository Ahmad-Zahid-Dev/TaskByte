import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/priority_selector.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final TaskModel? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _dateCtrl;
  late Priority _priority;
  String? _category;
  late DateTime _dueDate;
  bool _saving = false;

  bool get isEditing => widget.task != null;

  static const _categories = [
    AppStrings.personal,
    AppStrings.work,
    AppStrings.study,
    AppStrings.app,
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _dueDate = t?.dueDate ?? DateTime.now();
    _priority = t?.priority ?? Priority.medium;
    _category = t?.category;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _dateCtrl = TextEditingController(text: _formatDate(_dueDate));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final first = isEditing ? DateTime(2020) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dateCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prov = context.read<TaskProvider>();
    final now = DateTime.now();

    if (isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
      );
      await prov.updateTask(updated);
    } else {
      final task = TaskModel(
        id: 'task_${now.millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
        isCompleted: false,
        createdAt: now,
      );
      await prov.addTask(task);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? AppStrings.taskUpdated : AppStrings.taskAdded,
        ),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<TaskProvider>().deleteTask(widget.task!.id);
    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.taskDeleted),
        action: SnackBarAction(
          label: AppStrings.undo,
          textColor: AppColors.primaryLight,
          onPressed: () => context.read<TaskProvider>().undoDelete(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTask : AppStrings.newTask),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _delete,
              tooltip: AppStrings.deleteTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: AppStrings.titleLabel,
                hint: AppStrings.titleHint,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, label: 'Title'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descCtrl,
                label: AppStrings.descriptionLabel,
                hint: AppStrings.descriptionHint,
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _dateCtrl,
                label: AppStrings.dueDate,
                readOnly: true,
                onTap: _pickDate,
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                validator: (v) => Validators.required(v, label: 'Due date'),
              ),
              const SizedBox(height: 24),
              _Label(AppStrings.priority),
              const SizedBox(height: 10),
              PrioritySelector(
                selected: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 24),
              _Label(AppStrings.category),
              const SizedBox(height: 10),
              _CategoryPicker(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
                categories: _categories,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: isEditing ? AppStrings.updateTask : AppStrings.saveTask,
                onPressed: _save,
                loading: _saving,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.onChanged,
    required this.categories,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
