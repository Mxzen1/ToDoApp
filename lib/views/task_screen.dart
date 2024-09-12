import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../classes/class.dart';
import '../custom/add_task.dart'; 

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<Task> tasks = [];
  DateTime selectedDate = DateTime.now();

  String get selectedDateFormatted {
    final DateFormat formatter = DateFormat('EEEE, d MMMM yyyy');
    return formatter.format(selectedDate);
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddTaskBottomSheet(onTaskAdded: _addTask),
    );
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
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

  void _editTask(int taskIndex, int itemIndex, String newDescription) {
    setState(() {
      tasks[taskIndex].items[itemIndex].text = newDescription;
    });
  }

  void _deleteTask(int taskIndex, int itemIndex) {
    setState(() {
      tasks[taskIndex].items.removeAt(itemIndex);
      if (tasks[taskIndex].items.isEmpty) {
        tasks.removeAt(taskIndex);
      }
    });
  }

  Future<void> _pickTime(BuildContext context, int taskIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        tasks[taskIndex].time = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 16.0),
              child: Row(
                children: [
                  Text(
                    'Today',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 5.0),
                  child: Text(
                    selectedDateFormatted,
                    style: TextStyle(color: Colors.grey , fontSize: 20.0),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.grey),
                  onPressed: () => _selectDate(context),
                ),
               
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskListTile(
                  task: tasks[index],
                  onDelete: (itemIndex) => _deleteTask(index, itemIndex),
                  onToggleCompletion: (itemIndex) =>
                      _toggleTaskCompletion(index, itemIndex),
                  onToggleExpansion: () => _toggleTaskExpansion(index),
                  onEdit: (itemIndex, newDescription) => _editTask(index, itemIndex, newDescription),
                  onPickTime: () => _pickTime(context, index),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: 150,
          child: OutlinedButton(
            onPressed: () => _showAddTaskBottomSheet(context),
             style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.add,
            color: Colors.white,
          ),
          SizedBox(width: 20),
          Text('Add Task')],
          ),
        ),
      ),
      ),floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final Function(int) onDelete;
  final Function(int) onToggleCompletion;
  final VoidCallback onToggleExpansion;
  final Function(int, String) onEdit;
  final VoidCallback onPickTime;

  TaskListTile({
    required this.task,
    required this.onDelete,
    required this.onToggleCompletion,
    required this.onToggleExpansion,
    required this.onEdit,
    required this.onPickTime,
  });

  String _getTaskStatusText(Task task) {
    int completed = task.items.where((item) => item.isCompleted).length;
    if (completed == task.items.length) {
      return 'Completed';
    } else {
      return '$completed/${task.items.length}';
    }
  }

  Color _getTaskStatusColor(Task task) {
    int completed = task.items.where((item) => item.isCompleted).length;
    if (completed == task.items.length) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            ListTile(
              title: GestureDetector(
                onTap: onPickTime,
                child: Text(
                  task.time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              subtitle: Text(_getTaskStatusText(task)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTaskStatusText(task),
                    style: TextStyle(
                      color: _getTaskStatusColor(task),
                    ),
                  ),
                  Icon(task.isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              onTap: onToggleExpansion,
            ),
            if (task.isExpanded)
              Column(
                children: List.generate(task.items.length, (index) {
                  final taskItem = task.items[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: taskItem.isCompleted,
                              onChanged: (value) {
                                onToggleCompletion(index);
                              },
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: Text(
                                taskItem.text,
                                style: TextStyle(
                                  decoration: taskItem.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController _editController =
                                  TextEditingController(text: taskItem.text);
                              return AlertDialog(
                                title: Text('Edit Task Item'),
                                content: TextField(
                                  controller: _editController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  
                                  TextButton(
                                    onPressed: () {
                                      if (_editController.text.isNotEmpty) {
                                        onEdit(index, _editController.text);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text('Save'),
                                  ),
                                  
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.blue),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}