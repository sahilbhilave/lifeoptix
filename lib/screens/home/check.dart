import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double healthScore = 85.0;
  List<Task> tasks = [];
  double iconSize = 36.0;
  bool isHeartBeating = false;
  bool _isAddingTask = false;
  late User _user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadTasks();
  }

  void _loadTasks() async {
    print("Loading");
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('tasks')
            .orderBy('priority', descending: true) // Order by priority
            .get();

    tasks = snapshot.docs
        .map((doc) => Task(
              id: doc.id,
              name: doc['name'],
              deadline: (doc['deadline'] as Timestamp?)?.toDate(),
              priority: doc['priority'] ?? 5.0,
            ))
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text(
          '=',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              color: Colors.greenAccent,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Health Score',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$healthScore',
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 36.0, end: iconSize),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                iconSize = isHeartBeating ? 36.0 : 40.0;
                                isHeartBeating = !isHeartBeating;
                              });
                            },
                            child: Icon(
                              Icons.favorite,
                              size: value,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Today\'s Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('No tasks available'),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskListTile(
                        task: tasks[index],
                        onEdit: () => _showTaskEditor(context, tasks[index]),
                        onDelete: () =>
                            _showDeleteConfirmation(context, tasks[index]),
                        onComplete: () => _completeTask(tasks[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskAdder(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social Tasks',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Implement navigation logic based on the selected index
      // For example, you can use a switch statement to navigate to different screens
      switch (index) {
        case 0:
          // Navigate to the Navigation screen
          break;
        case 1:
          // Navigate to the Nutrition screen
          break;
        case 2:
          // Navigate to the Exercise screen
          break;
        case 3:
          // Navigate to the Meditation screen
          break;
        case 4:
          // Navigate to the Social Tasks screen
          break;
      }
    });
  }

  Future<void> _showTaskAdder(BuildContext context) async {
    String taskName = '';
    DateTime? deadline;

    setState(() {
      _isAddingTask = true;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskAdderDialog(
          onTaskAdded: (name, selectedDeadline, priority) async {
            await _addTaskToFirestore(name, selectedDeadline, priority);
            _loadTasks(); // Refresh the task list
            Navigator.of(context).pop();
            setState(() {
              _isAddingTask = false;
            });
          },
        );
      },
    );
  }

  Future<void> _showTaskEditor(BuildContext context, Task task) async {
    String editedTaskName = task.name;
    DateTime? editedDeadline = task.deadline;
    double editedPriority = task.priority;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskEditorDialog(
          task: task,
          onTaskUpdated: (name, selectedDeadline, priority) async {
            await _updateTaskInFirestore(
                task.id, name, selectedDeadline, priority);
            _loadTasks(); // Refresh the task list
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Task task) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteTask(task);
    }
  }

  Future<void> _addTaskToFirestore(
      String name, DateTime? deadline, double priority) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'name': name,
        'deadline': deadline,
        'priority': priority,
      });

      print("Task added successfully.");
    }
  }

  Future<void> _updateTaskInFirestore(
      String taskId, String name, DateTime? deadline, double priority) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update task data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({
        'name': name,
        'deadline': deadline,
        'priority': priority,
      });

      print("Task updated successfully.");
    }
  }

  Future<void> _deleteTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Delete task from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .delete();

      _loadTasks(); // Refresh the task list
      print("Task deleted successfully.");
    }
  }

  Future<void> _completeTask(Task task) async {
    _deleteTask(task);
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  TaskListTile({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deadline: ${task.formattedDeadline}',
          ),
          Text(
            'Priority: ${task.formattedPriority}',
          ),
        ],
      ),
      trailing: Container(
        // margin: EdgeInsets.all(0),
        //width: 15,
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
          ),
          elevation: 4,
          onSelected: (String value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            } else if (value == 'complete') {
              onComplete();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  title: Icon(
                    Icons.edit,
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  title: Icon(Icons.delete),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'complete',
                child: ListTile(
                  title: Icon(Icons.check),
                ),
              ),
            ];
          },
          offset: const Offset(0, 2), // Adjust the vertical offset as needed
        ),
      ),
    );
  }
}

class TaskEditorDialog extends StatefulWidget {
  final Task task;
  final Function(String, DateTime?, double) onTaskUpdated;

  const TaskEditorDialog({
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  _TaskEditorDialogState createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  late TextEditingController _taskNameController;
  late DateTime? _deadline;
  late double _priority;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task.name);
    _deadline = widget.task.deadline;
    _priority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: _deadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _deadline = selectedDate;
                });
              }
            },
            child: const Text('Select Deadline'),
          ),
          const SizedBox(height: 16),
          Text('Set Priority: $_priority'),
          Slider(
            value: _priority,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _priority = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onTaskUpdated(
                _taskNameController.text, _deadline, _priority);
          },
          child: const Text('Update Task'),
        ),
      ],
    );
  }
}

class TaskAdderDialog extends StatefulWidget {
  final Function(String, DateTime?, double) onTaskAdded;

  const TaskAdderDialog({required this.onTaskAdded});

  @override
  _TaskAdderDialogState createState() => _TaskAdderDialogState();
}

class _TaskAdderDialogState extends State<TaskAdderDialog> {
  late TextEditingController _taskNameController;
  DateTime? _deadline;
  double _priority = 5.0;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _deadline = selectedDate;
                });
              }
            },
            child: const Text('Select Deadline'),
          ),
          const SizedBox(height: 16),
          Text('Set Priority: $_priority'),
          Slider(
            value: _priority,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _priority = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onTaskAdded(_taskNameController.text, _deadline, _priority);
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}

class Task {
  final String id;
  final String name;
  final DateTime? deadline;
  double priority;

  Task(
      {required this.id,
      required this.name,
      required this.deadline,
      this.priority = 5.0});

  String get formattedDeadline => deadline != null
      ? deadline!.toLocal().toString().split(' ')[0]
      : "No deadline";

  String get formattedPriority => priority.toStringAsFixed(1);
}

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
