import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';
import 'package:taskflow/features/tasks/data/datasource/task_local_datasource.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';
import 'package:taskflow/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow/features/tasks/domain/usecases/add_task.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task.dart';
import 'package:taskflow/features/tasks/domain/usecases/get_tasks.dart';
import 'package:taskflow/features/tasks/domain/usecases/update_task.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_event.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  final box = await Hive.openBox<TaskModel>('tasks');

  final dataSource = TaskLocalDataSource(box);
  final repository = TaskRepositoryImpl(dataSource);
  final themeBox = await Hive.openBox('theme');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(themeBox)),
        BlocProvider(
          create: (_) => TaskBloc(
            addTask: AddTask(repository),
            getTasks: GetTasks(repository),
            deleteTask: DeleteTask(repository),
            updateTask: UpdateTask(repository),
          )..add(LoadTasksEvent()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const TaskPage(),
        );
      },
    );
  }
}
