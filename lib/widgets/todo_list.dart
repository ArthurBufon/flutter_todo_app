import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // Firebase instance.
  var db = FirebaseFirestore.instance;

  final Stream<QuerySnapshot> _taskStream =
      FirebaseFirestore.instance.collection('tasks').snapshots();

  // Inicializa state.
  @override
  void initState() {
    super.initState();
  }

  // Add new task to tasks collection.
  void addTask() {
    // New task.
    final task = <String, dynamic>{
      "title": "Laravel",
      "description": "Learn Repository Pattern in Laravel.",
      "tag": "work",
    };

    // Persist to collection in database.
    db
        .collection("tasks")
        .add(task)
        .then((DocumentReference doc) => print('Stored. Task id: ${doc.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.deepPurple,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error!');
          }
          if (!snapshot.hasData) {
            return const Text('Empty!');
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final data = document.data()! as Map<String, dynamic>;

              return ListTile(
                leading:
                    Icon((data['tag'] == 'work') ? Icons.work : Icons.backpack),
                title: Text(data['title']),
                subtitle: Text(data['description']),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
