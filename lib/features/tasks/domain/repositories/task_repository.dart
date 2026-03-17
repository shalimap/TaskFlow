import 'package:taskflow/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  List<Task> getTasks();
  Future<void> addTask(Task task);

  Future<void> deleteTask(String id);

  Future<void> updateTask(Task task);
}
