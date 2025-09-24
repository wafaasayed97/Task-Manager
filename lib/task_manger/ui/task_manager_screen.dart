import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/task_manger/data/models/task_model.dart';

class TaskManagementWidget extends StatefulWidget {
  const TaskManagementWidget({super.key});

  @override
  TaskManagementWidgetState createState() => TaskManagementWidgetState();
}

class TaskManagementWidgetState extends State<TaskManagementWidget> {
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'Complete Flutter Project',
      description:
          'Finish the task management app with dismissible functionality',
    ),
    Task(
      id: '2',
      title: 'Review Code',
      description: 'Review pull requests and provide feedback to team members',
    ),
    Task(
      id: '3',
      title: 'Update Documentation',
      description: 'Update API documentation and user guides',
    ),
    Task(
      id: '4',
      title: 'Plan Sprint Meeting',
      description: 'Prepare agenda and user stories for next sprint planning',
    ),
  ];

  Task? lastDeletedTask;
  int? lastDeletedIndex;

  Future<bool> _showDeleteConfirmationDialog(Task task) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _deleteTask(int index) async {
    final task = tasks[index];
    final shouldDelete = await _showDeleteConfirmationDialog(task);

    if (shouldDelete) {
      setState(() {
        lastDeletedTask = task;
        lastDeletedIndex = index;
        tasks.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" deleted'),
          action: SnackBarAction(label: 'UNDO', onPressed: _undoDelete),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _undoDelete() {
    if (lastDeletedTask != null && lastDeletedIndex != null) {
      setState(() {
        tasks.insert(lastDeletedIndex!, lastDeletedTask!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${lastDeletedTask!.title}" restored'),
          duration: const Duration(seconds: 2),
        ),
      );

      lastDeletedTask = null;
      lastDeletedIndex = null;
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index] = tasks[index].copyWith(
        isCompleted: !tasks[index].isCompleted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Task Management'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.inversePrimary.withOpacity(0.2),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {}),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No tasks available',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: EdgeInsets.all(8.sp),
              itemCount: tasks.length,
              onReorder: _reorderTasks,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 28.sp),
                  ),
                  confirmDismiss: (direction) async {
                    _deleteTask(index);
                    return false;
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 8.w,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_handle,
                          color: Colors.grey,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted ? Colors.grey : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        task.description,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _toggleTaskCompletion(index),
                      ),
                      onTap: () => _toggleTaskCompletion(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // void _addNewTask() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       final titleController = TextEditingController();
  //       final descriptionController = TextEditingController();

  //       return AlertDialog(
  //         title: const Text('Add New Task'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: titleController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Task Title',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             SizedBox(height: 16.h),
  //             TextField(
  //               controller: descriptionController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Description',
  //                 border: OutlineInputBorder(),
  //               ),
  //               maxLines: 3,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               if (titleController.text.trim().isNotEmpty) {
  //                 setState(() {
  //                   tasks.add(
  //                     Task(
  //                       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //                       title: titleController.text.trim(),
  //                       description: descriptionController.text.trim(),
  //                     ),
  //                   );
  //                 });
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //             child: const Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
