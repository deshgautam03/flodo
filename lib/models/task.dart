import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  bool isCompleted = false;

  DateTime? dueDate;

  late String priority;

  String? category;

  String? blockedBy;

  int? blockedById;
}
