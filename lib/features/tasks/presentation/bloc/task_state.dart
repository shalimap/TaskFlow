import '../../domain/entities/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;

  TaskLoaded({required this.tasks, required this.filteredTasks});
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}
