import 'package:hive/hive.dart';
import 'classes/class.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final time = reader.readString();
    final items = reader.readList().cast<TaskItem>();
    final isExpanded = reader.readBool();
    return Task(time: time, items: items, isExpanded: isExpanded);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.time);
    writer.writeList(obj.items);
    writer.writeBool(obj.isExpanded);
  }
}

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final typeId = 1;

  @override
  TaskItem read(BinaryReader reader) {
    final text = reader.readString();
    final isCompleted = reader.readBool();
    return TaskItem(text: text, isCompleted: isCompleted);
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer.writeString(obj.text);
    writer.writeBool(obj.isCompleted);
  }
}
