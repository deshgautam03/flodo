import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'highlighted_text.dart';

class TaskListTile extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onDelete;
  final String? searchQuery;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.onDelete,
    this.searchQuery,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.tertiary; // pinkish red
      case 'Low':
        return AppTheme.primary; // soft purple
      default:
        return AppTheme.secondary; // violet
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.tertiary.withValues(alpha: 0.2);
      case 'Low':
        return AppTheme.primary.withValues(alpha: 0.2);
      default:
        return AppTheme.secondary.withValues(alpha: 0.2);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reactive logic to check if this task is blocked
    final tasksAsync = ref.watch(taskProvider);
    final allTasks = tasksAsync.valueOrNull ?? [];
    
    Task? blockingTask;
    bool isBlocked = false;
    
    if (task.blockedById != null) {
      blockingTask = allTasks.cast<Task?>().firstWhere(
        (t) => t?.id == task.blockedById,
        orElse: () => null,
      );
      // Blocked if blocking task exists and is NOT done
      if (blockingTask != null && !blockingTask.isCompleted) {
        isBlocked = true;
      }
    }

    final cardColor = task.isCompleted 
        ? AppTheme.surfaceContainerLow.withValues(alpha: 0.6) 
        : (isBlocked ? Colors.grey.withValues(alpha: 0.2) : AppTheme.surfaceContainerLow);

    return Opacity(
      opacity: isBlocked ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: (task.isCompleted || isBlocked) ? Border.all(color: Colors.transparent) : null,
        ),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: isBlocked ? null : onTap, // Disable interaction if blocked
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isBlocked 
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : (task.isCompleted ? const Color(0xFF4CAF50).withValues(alpha: 0.2) : _getPriorityBgColor(task.priority)),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              task.isCompleted ? 'DONE' : (isBlocked ? 'BLOCKED' : task.priority.toUpperCase()),
                              style: TextStyle(
                                color: isBlocked 
                                    ? Colors.grey 
                                    : (task.isCompleted ? const Color(0xFF4CAF50) : _getPriorityColor(task.priority)),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          task.isCompleted
                              ? const Icon(Icons.check_circle, color: AppTheme.tertiaryDim, size: 20)
                              : (isBlocked 
                                  ? const Icon(Icons.lock_outline, color: Colors.grey, size: 20)
                                  : Checkbox(
                                      value: task.isCompleted,
                                      onChanged: onCheckboxChanged,
                                      visualDensity: VisualDensity.compact,
                                    )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      (searchQuery != null && searchQuery!.isNotEmpty)
                          ? HighlightedText(
                              text: task.title,
                              query: searchQuery!,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: (task.isCompleted || isBlocked) ? AppTheme.onSurface.withValues(alpha: 0.5) : AppTheme.onSurface,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                              highlightStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isBlocked ? Colors.grey : AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                            )
                          : Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: (task.isCompleted || isBlocked) ? AppTheme.onSurface.withValues(alpha: 0.5) : AppTheme.onSurface,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                            ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: (task.isCompleted || isBlocked) ? AppTheme.onSurfaceVariant.withValues(alpha: 0.4) : AppTheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: task.dueDate != null
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 16,
                                        color: (task.isCompleted || isBlocked) ? AppTheme.onSurfaceVariant.withValues(alpha: 0.3) : AppTheme.primaryDim.withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'DUE ${DateFormat('MMM d, yyyy').format(task.dueDate!).toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: (task.isCompleted || isBlocked) ? AppTheme.onSurfaceVariant.withValues(alpha: 0.3) : AppTheme.primaryDim.withValues(alpha: 0.8),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                          GestureDetector(
                            onTap: onDelete,
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppTheme.errorDim.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      if (isBlocked && blockingTask != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Blocked by: ${blockingTask.title}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (isBlocked)
              const Positioned(
                top: 16,
                right: 16,
                child: Icon(Icons.lock, color: Colors.amber, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}
