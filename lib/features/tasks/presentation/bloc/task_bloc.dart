import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/update_task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final AddTask addTask;
  final GetTasks getTasks;
  final DeleteTask deleteTask;
  final UpdateTask updateTask;

  TaskBloc({
    required this.addTask,
    required this.getTasks,
    required this.deleteTask,
    required this.updateTask,
  }) : super(TaskInitial()) {
    // LOAD TASKS
    on<LoadTasksEvent>((event, emit) {
      emit(TaskLoading());
      final tasks = getTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    });

    // ADD TASK
    on<AddTaskEvent>((event, emit) async {
      await addTask(event.task);
      final tasks = getTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    });

    // DELETE TASK
    on<DeleteTaskEvent>((event, emit) async {
      await deleteTask(event.id);
      final tasks = getTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    });

    // UPDATE TASK
    on<UpdateTaskEvent>((event, emit) async {
      await updateTask(event.task);
      final tasks = getTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    });

    // SEARCH
    on<SearchTaskEvent>((event, emit) {
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;

        final filtered = currentState.tasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();

        emit(TaskLoaded(tasks: currentState.tasks, filteredTasks: filtered));
      }
    });
  }
}
