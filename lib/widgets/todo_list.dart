import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/widgets/task/edit_task.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // Firebase instance.
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Snapshot contém todos os documentos da coleção tasks do firestore.
      stream: db.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        // Erro na snapshot.
        if (snapshot.hasError) {
          return const Text('Error!');
        }
        // Snapshot vazio.
        if (!snapshot.hasData) {
          return const Text('Empty!');
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            // Transforma snapshot dos documentos em um map (array com keys e values).
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            // Faz 1 card para cada item do map data.
            return Card(
              color: const Color.fromARGB(255, 252, 252, 252),
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(
                  (data['tag'] == 'work') ? Icons.work : Icons.backpack,
                  size: 30,
                ),
                title: Text(data['title']),
                subtitle: Text(data['description']),
                // Navigate to edit task screen.
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTask(taskId: document.id, taskData: data),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
