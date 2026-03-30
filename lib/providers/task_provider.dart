import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task.dart';
import 'database_provider.dart';

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final isar = await ref.read(isarProvider.future);
    try {
      return await isar.tasks.where().findAll();
    } catch (e) {
      await isar.writeTxn(() async {
        await isar.clear();
      });
      return [];
    }
  }

  Future<void> addTask(Task task) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    state = await AsyncValue.guard(() => _fetchTasks());
  }

  Future<void> updateTask(Task task) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    state = await AsyncValue.guard(() => _fetchTasks());
  }

  Future<void> deleteTask(int id) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
    state = await AsyncValue.guard(() => _fetchTasks());
  }
}
