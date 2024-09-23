  import 'package:flutter/material.dart';
  import 'package:hive/hive.dart';
  import 'package:hive_flutter/hive_flutter.dart';
  import 'views/task_screen.dart';
  import 'classes/class.dart'; // Your class file
  import 'hive_adapters.dart'; // Manually created adapter file

  void main() async {
    await Hive.initFlutter();

    // Register the manually created adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskItemAdapter());

    // Open the Hive box to store tasks
    await Hive.openBox<Task>('tasksBox');

    runApp(MyApp());
  }

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'To Do App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TaskHomePage(),
        debugShowCheckedModeBanner: false,
      );
    }
  }
