import 'package:hive/hive.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Task {
  @HiveField(0)
  final String taskId;

  @HiveField(1)
  final String taskTitle;

  @HiveField(2)
  final String taskDescription;

  @HiveField(3)
  final bool completed;

  const TaskModel({
    required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    required this.completed,
  }) : super(
         id: taskId,
         title: taskTitle,
         description: taskDescription,
         isCompleted: completed,
       );

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      taskId: task.id,
      taskTitle: task.title,
      taskDescription: task.description,
      completed: task.isCompleted,
    );
  }

  Task toEntity() {
    return Task(
      id: taskId,
      title: taskTitle,
      description: taskDescription,
      isCompleted: completed,
    );
  }
}
