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
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10) ,
              boxShadow: [BoxShadow(
                color: Colors.grey,
                blurRadius:5)
                ],
              color: Colors.teal,
              gradient: LinearGradient(colors: [Colors.yellow,Colors.pink],
              )
            ),
            child: Text("i am a box"),
          ),
        )
     
    );
  }
}