import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';

import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'package:lottie/lottie.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("TaskFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),

      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Loading
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Loaded
          if (state is TaskLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/animations/embty cart.json',
                      height: 200,
                    ),

                    const SizedBox(height: 20),

                    const Text("No Tasks Yet", style: TextStyle(fontSize: 18)),

                    const SizedBox(height: 10),

                    const Text(
                      "Add your first task 🚀",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search tasks...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      context.read<TaskBloc>().add(SearchTaskEvent(value));
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];

                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        tween: Tween(begin: 0.0, end: 1.0),

                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },

                        child: Dismissible(
                          key: Key(task.id),

                          direction: DismissDirection.endToStart,

                          onDismissed: (_) {
                            bool _isUndoActive = false;
                            if (_isUndoActive) return; // prevent stacking

                            _isUndoActive = true;

                            context.read<TaskBloc>().add(
                              DeleteTaskEvent(task.id),
                            );
                            final messenger = ScaffoldMessenger.of(context);
                            // ..hideCurrentSnackBar()
                            // ..showSnackBar(
                            messenger.clearSnackBars();
                            messenger
                                .showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 5),
                                    content: Text("${task.title} deleted"),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      onPressed: () {
                                        context.read<TaskBloc>().add(
                                          AddTaskEvent(task),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .closed
                                .then((_) {
                                  // reset after snackbar disappears
                                  _isUndoActive = false;
                                });
                          },

                          background: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.red.withValues(alpha: 0.8),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          child: _buildTaskItem(context, task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Default / Error
          return const Center(child: Text("Something went wrong"));
        },
      ),

      // Add Task Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Glass Task Card
  Widget _buildTaskItem(BuildContext context, Task task) {
    return Padding(
      padding: const EdgeInsets.all(10),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),

              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  context.read<TaskBloc>().add(
                    UpdateTaskEvent(
                      task.copyWith(isCompleted: !task.isCompleted),
                    ),
                  );
                },
              ),

              onLongPress: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              },
            ),
          ),
        ),
      ),
    );
  }

  // Add Task Dialog
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Task"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                context.read<TaskBloc>().add(
                  AddTaskEvent(
                    Task(
                      id: DateTime.now().toString(),
                      title: titleController.text,
                      description: descController.text,
                      isCompleted: false,
                    ),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
