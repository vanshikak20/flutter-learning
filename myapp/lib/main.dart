import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "awesome app", //when we minimise the app
    home: HomePage(), //needs to define if it is stateless or statefull
  ));
}

class HomePage extends StatelessWidget { //here defines
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("awesome app"),  //actual title
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Center(child: Text("hiooo flutter")),
      ),
    );
  }
}