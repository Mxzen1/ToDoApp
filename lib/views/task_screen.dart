import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:hive/hive.dart';
import '../classes/class.dart';
import '../custom/add_task.dart';

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasksFromHive();
  }

  void _loadTasksFromHive() {
    final taskBox = Hive.box<Task>('tasksBox');
    setState(() {
      tasks = taskBox.values.toList();
    });
  }

  void _addTask(Task task) async {
    final taskBox = Hive.box<Task>('tasksBox');
    await taskBox.add(task);
    setState(() {
      tasks.add(task);
    });
  }

  void _deleteTask(int taskIndex, int itemIndex) async {
    setState(() {
      tasks[taskIndex].items.removeAt(itemIndex);
      if (tasks[taskIndex].items.isEmpty) {
        Hive.box<Task>('tasksBox').deleteAt(taskIndex);
        tasks.removeAt(taskIndex);
      }
    });
  }

  void _toggleTaskCompletion(int taskIndex, int itemIndex) {
    setState(() {
      tasks[taskIndex].items[itemIndex].isCompleted =
          !tasks[taskIndex].items[itemIndex].isCompleted;
    });
  }

  void _toggleTaskExpansion(int taskIndex) {
    setState(() {
      tasks[taskIndex].isExpanded = !tasks[taskIndex].isExpanded;
    });
  }

  void _editTaskItem(int taskIndex, int itemIndex, String newDescription) {
    setState(() {
      tasks[taskIndex].items[itemIndex].text = newDescription;
      tasks[taskIndex].items[itemIndex].isCompleted = false;
      Hive.box<Task>('tasksBox').putAt(taskIndex, tasks[taskIndex]);
    });
  }

  void _editTaskTime(int taskIndex, String newTime) {
    setState(() {
      tasks[taskIndex].time = newTime;
      Hive.box<Task>('tasksBox').putAt(taskIndex, tasks[taskIndex]);
    });
  }

  void _showEditTaskItemDialog(BuildContext context, int taskIndex, int itemIndex) {
    final item = tasks[taskIndex].items[itemIndex];
    final TextEditingController controller = TextEditingController(text: item.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task Item"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Task Description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _editTaskItem(taskIndex, itemIndex, controller.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskTimeDialog(BuildContext context, int taskIndex) {
    final Task task = tasks[taskIndex];
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task Time"),
          content: Text("Current time: ${task.time}"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                  _editTaskTime(taskIndex, selectedTime.format(context));
                  Navigator.pop(context);
                }
              },
              child: Text("Pick Time"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddTaskBottomSheet(onTaskAdded: _addTask),
    );
  }


  String _getFormattedDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yMMMMd');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today is',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5), 
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskListTile(
                  task: tasks[index],
                  onDelete: (itemIndex) => _deleteTask(index, itemIndex),
                  onToggleCompletion: (itemIndex) =>
                      _toggleTaskCompletion(index, itemIndex),
                  onToggleExpansion: () => _toggleTaskExpansion(index),
                  onEditItem: (itemIndex) =>
                      _showEditTaskItemDialog(context, index, itemIndex),
                  onEditTime: () => _showEditTaskTimeDialog(context, index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: TextButton(
                onPressed: () => _showAddTaskBottomSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    Text(
                      " Add Task",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final Function(int) onDelete;
  final Function(int) onToggleCompletion;
  final VoidCallback onToggleExpansion;
  final Function(int) onEditItem;
  final VoidCallback onEditTime;

  TaskListTile({
    required this.task,
    required this.onDelete,
    required this.onToggleCompletion,
    required this.onToggleExpansion,
    required this.onEditItem,
    required this.onEditTime,
  });

  // Function to count completed task items
  int _getCompletedItemCount() {
    return task.items.where((item) => item.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = _getCompletedItemCount();
    final int totalCount = task.items.length;

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(task.time), // Display task time
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEditTime, // Edit task time
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(0), // Delete the task
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display "Completed" if all items are checked, otherwise show progress (e.g., "2/3 completed")
          Text(
            completedCount == totalCount && totalCount > 0
                ? 'Completed' // Show "Completed" if all items are done
                : '$completedCount/$totalCount completed', // Show count of completed items
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: completedCount == totalCount && totalCount > 0
                  ? Colors.green // Green color for fully completed tasks
                  : Colors.black, // Default color for incomplete tasks
            ),
          ),
        ],
      ),
      onTap: onToggleExpansion, // Toggle expansion of the task
      subtitle: Column(
        children: List.generate(task.items.length, (index) {
          final item = task.items[index];
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Apply strikethrough if the task item is completed
                Text(
                  item.text,
                  style: TextStyle(
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough // Strikethrough for completed items
                        : TextDecoration.none, // No strikethrough for incomplete items
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onEditItem(index), // Edit the task item
                ),
              ],
            ),
            trailing: Checkbox(
              value: item.isCompleted,
              onChanged: (val) => onToggleCompletion(index), // Toggle task completion
            ),
          );
        }),
      ),
    );
  }
}
