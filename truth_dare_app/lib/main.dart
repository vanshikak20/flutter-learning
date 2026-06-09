import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Random rnd = Random();

  int currentIndex = 0;
  int completedCount = 0;

  void completeTask() {
    int newIndex;

    do {
      newIndex = rnd.nextInt(4);
    } while (newIndex == currentIndex);

    setState(() {
      completedCount++;
      currentIndex = newIndex;
    });
  }

  void forfeitTask() {
    int newIndex;

    do {
      newIndex = rnd.nextInt(4);
    } while (newIndex == currentIndex);

    setState(() {
      currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Truth & Dare"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Completed: $completedCount",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          IndexedStack(
            index: currentIndex,
            children: const [
              QuestionCard(
                questionName: "What is your name?",
                color: Colors.cyan,
              ),
              QuestionCard(
                questionName: "What is your age?",
                color: Colors.red,
              ),
              QuestionCard(
                questionName: "What is your dream job?",
                color: Colors.green,
              ),
              QuestionCard(
                questionName: "Who is your best friend?",
                color: Colors.orange,
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 60,
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: completeTask,
                  child: const Text(
                    "Completed",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(
                height: 60,
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: forfeitTask,
                  child: const Text(
                    "Forfeit",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String questionName;
  final Color color;

  const QuestionCard({
    super.key,
    required this.questionName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              questionName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}