import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'views/home_view.dart';
import 'views/task_form_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeView()),
        GetPage(name: '/task_form', page: () => const TaskFormView()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
