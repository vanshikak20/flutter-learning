import 'package:flutter/material.dart';

class Todolist extends StatelessWidget {
  const Todolist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title : Text("Theme"),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(3,3,1,2),
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
                
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "hello",
                style : Theme.of(context).textTheme.headlineMedium,
                ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(3,3,1,2),
            height: 200,
            width:200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
      
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Beautiful",
                style : Theme.of(context).textTheme.headlineMedium,
                ),
            ),
          ),
      
          Container(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text('open dash')),
      ),
        ],
      ),
    );
  }
}
