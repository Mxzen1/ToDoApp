class Task {
  String time;
  List<TaskItem> items;
  bool isExpanded;

  Task({required this.time, required this.items, this.isExpanded = false});
}

class TaskItem {
  String text;
  bool isCompleted;

  TaskItem({required this.text, this.isCompleted = false});
}
