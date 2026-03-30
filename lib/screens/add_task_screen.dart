import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  String _selectedStatus = 'To-Do';
  String? _selectedBlockedBy;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate;
    
    final priority = widget.task?.priority ?? 'To-Do';
    if (['To-Do', 'In Progress', 'Done'].contains(priority)) {
      _selectedStatus = priority;
    } else {
      _selectedStatus = 'To-Do';
    }
    
    _selectedBlockedBy = widget.task?.blockedBy;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = widget.task ?? Task();
      task.title = _titleController.text;
      task.description = _descController.text.isEmpty ? null : _descController.text;
      task.dueDate = _selectedDate;
      task.priority = _selectedStatus; // mapped to priority field
      task.isCompleted = _selectedStatus == 'Done';
      
      // Handle Blocked By
      if (_selectedBlockedBy == null || 
          _selectedBlockedBy == 'None (not blocked)' || 
          _selectedBlockedBy == 'No other tasks available') {
        task.blockedBy = null;
        task.blockedById = null;
      } else {
        task.blockedBy = _selectedBlockedBy;
        // We need to find the ID for this title. 
        // Note: This assumes titles are unique for simplicity in selection,
        // but we fetch tasks again to be sure.
        final allTasks = ref.read(taskProvider).valueOrNull ?? [];
        final blockingTask = allTasks.cast<Task?>().firstWhere(
          (t) => t?.title == _selectedBlockedBy && t?.id != widget.task?.id,
          orElse: () => null,
        );
        task.blockedById = blockingTask?.id;
      }
      
      if (widget.task == null) {
        await ref.read(taskProvider.notifier).addTask(task);
      } else {
        await ref.read(taskProvider.notifier).updateTask(task);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch tasks to populate the Blocked By dropdown
    final tasksAsyncValue = ref.watch(taskProvider);
    final existingTasks = tasksAsyncValue.valueOrNull ?? [];
    
    // Filter out the current task if editing
    final availableBlockingTasks = existingTasks
        .where((t) => t.id != widget.task?.id)
        .toList();
    
    final bool noTasks = availableBlockingTasks.isEmpty;
    
    // Default options
    final List<String> blockedByOptions = noTasks 
        ? ['No other tasks available'] 
        : ['None (not blocked)', ...availableBlockingTasks.map((t) => t.title)];

    // Find current display value
    String currentDisplayName = 'None (not blocked)';
    if (noTasks) {
      currentDisplayName = 'No other tasks available';
    } else if (widget.task?.blockedById != null) {
      // Try to find the task by ID first for accuracy
      final blockingTask = existingTasks.cast<Task?>().firstWhere(
        (t) => t?.id == widget.task?.blockedById,
        orElse: () => null,
      );
      if (blockingTask != null) {
        currentDisplayName = blockingTask.title;
      }
    } else if (widget.task?.blockedBy != null) {
      // Fallback to title if ID is missing (legacy)
      currentDisplayName = widget.task!.blockedBy!;
    }
    
    final currentSelection = blockedByOptions.contains(currentDisplayName) 
        ? currentDisplayName 
        : (noTasks ? 'No other tasks available' : 'None (not blocked)');

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add notes or description...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      // Unfocus all fields BEFORE showing the date picker
                      FocusScope.of(context).unfocus();
                      
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (mounted) {
                        FocusScope.of(context).unfocus();
                      }
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppTheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate == null 
                                ? 'No Due Date' 
                                : DateFormat('MMM d, yyyy').format(_selectedDate!),
                              style: Theme.of(context).textTheme.labelLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.onSurfaceVariant),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    dropdownColor: AppTheme.surfaceContainerHigh,
                    items: ['To-Do', 'In Progress', 'Done'].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p, style: Theme.of(context).textTheme.bodyMedium));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: currentSelection,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.onSurfaceVariant),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    dropdownColor: AppTheme.surfaceContainerHigh,
                    items: blockedByOptions.toSet().map((p) {
                      return DropdownMenuItem(value: p, child: Text(p, style: Theme.of(context).textTheme.bodyMedium));
                    }).toList(),
                    onChanged: noTasks ? null : (val) {
                      if (val != null) {
                        setState(() => _selectedBlockedBy = (val == 'None (not blocked)' || val == 'No other tasks available') ? null : val);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    onPressed: _saveTask,
                    hasShadow: true,
                    child: Text(
                      widget.task == null ? 'CREATE TASK' : 'SAVE CHANGES',
                      style: const TextStyle(
                        color: AppTheme.onPrimaryFixed,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
