import 'package:flutter/material.dart';
import '../classes/class.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  AddTaskBottomSheet({required this.onTaskAdded});

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final List<TaskItem> _items = []; // List to hold task items
  TimeOfDay? _selectedTime;
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _taskItemController = TextEditingController(); 


  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Add task item to the list
  void _addTaskItem() {
    final itemDescription = _taskItemController.text;
    if (itemDescription.isNotEmpty) {
      setState(() {
        _items.add(TaskItem(text: itemDescription)); // Add item to the list
        _taskItemController.clear(); // Clear the input field after adding
      });
    }
  }

  // Add the task with all task items
  void _addTask() {
    if (_selectedTime != null && _items.isNotEmpty) {
      widget.onTaskAdded(
        Task(time: _selectedTime!.format(context), items: _items),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To prevent excessive height
        children: [
          // Button to pick time
          ElevatedButton(
            onPressed: () => _pickTime(context),
            child: Text(_selectedTime == null ? 'Select Time' : 'Selected Time: ${_selectedTime!.format(context)}'),
          ),
          
          // Input field for the task item description
          TextField(
            controller: _taskItemController,
            decoration: InputDecoration(
              labelText: 'Task Item',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addTaskItem, // Add the task item on click
              ),
            ),
          ),

          // Displaying the list of added task items
          ListView.builder(
            shrinkWrap: true, // Ensures the list doesn't take too much space
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                title: Text(item.text),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index); // Remove item from the list
                    });
                  },
                ),
              );
            },
          ),

          // Button to add the task
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
