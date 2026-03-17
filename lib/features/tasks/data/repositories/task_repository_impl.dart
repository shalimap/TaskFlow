import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasource/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  List<Task> getTasks() {
    final models = localDataSource.getTasks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.addTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.updateTask(model);
  }
}