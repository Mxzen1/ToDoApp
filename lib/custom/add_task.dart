import 'package:flutter/material.dart';
import '../classes/class.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  AddTaskBottomSheet({required this.onTaskAdded});

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final List<TaskItem> _items = [];
  TimeOfDay? _selectedTime;
  final TextEditingController _taskDescriptionController = TextEditingController();

  Future<void> _pickTime(BuildContext context) async {
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addTaskItem() {
    final String taskDescription = _taskDescriptionController.text;
    if (taskDescription.isNotEmpty) {
      setState(() {
        _items.add(TaskItem(text: taskDescription));
        _taskDescriptionController.clear();
      });
    }
  }

  void _addTask() {
    if (_selectedTime != null && _items.isNotEmpty) {
      widget.onTaskAdded(
        Task(
          time: _selectedTime!.format(context),
          items: _items,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _pickTime(context),
                child: Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : 'Selected Time: ${_selectedTime!.format(context)}',
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: _taskDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addTaskItem,
                child: Text('+' , style: TextStyle(fontSize: 17),),
              ),
              SizedBox(height: 14),
              if (_items.isNotEmpty) ...[
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_items[index].text),
                      tileColor: Colors.grey[200],
                      contentPadding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blueAccent),
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: 14),
              ElevatedButton(
                onPressed: _addTask,
                child: Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}