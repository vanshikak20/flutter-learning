import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List todoList = [
    ["Workout", false],
    ["Study Flutter", false],
    ["Practice DSA", false],
  ];

  final TextEditingController controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      todoList[index][1] = !todoList[index][1];
    });
  }

  void saveNewTask() {
    setState(() {
      todoList.add([controller.text, false]);
    });

    controller.clear();
    Navigator.pop(context);
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 150, 230, 250),
          content: SizedBox(
            height: 120,
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Create New Task",
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: saveNewTask,
                      child: const Icon(Icons.save),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.cancel),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 114, 111),

      appBar: AppBar(
        title: const Text("TO DO"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 105, 220, 230),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15),

            child: Slidable(
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      deleteTask(index);
                    },
                    icon: Icons.delete,
                    backgroundColor: const Color.fromARGB(255, 242, 235, 234),
                  ),
                ],
              ),

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 105, 220, 230),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: todoList[index][1],
                      onChanged: (value) {
                        checkBoxChanged(value, index);
                      },
                    ),

                    Text(
                      todoList[index][0],
                      style: TextStyle(
                        decoration: todoList[index][1]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
