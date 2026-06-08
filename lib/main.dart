import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_demo.dart';
import 'screens/nav_drawer.dart';
import 'screens/todo_list.dart';
void main() {
  runApp(const MyWidget());
}
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 118, 152, 220),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 27, 76, 132),
        ),
      ),
      initialRoute: '/todo',
      routes: {
        "/": (context) => HomePage(),
        "/draw": (context) => nav_drawer(),
        "/todo" :(context) => Todolist(),
      },
    );
  }
}  