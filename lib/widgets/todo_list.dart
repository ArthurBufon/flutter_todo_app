import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/widgets/task/edit_task.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // Firebase instance.
  var db = FirebaseFirestore.instance;

  // Exclui item da lista.
  void _deleteTaskItem(String taskId) {
    db.collection("tasks").doc(taskId).delete().then(
          (doc) => // Toast success
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color.fromARGB(255, 101, 225, 105),
            content: Text("Task deleted successfully!"),
          )),
          onError: (e) =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color.fromARGB(255, 241, 117, 117),
            content: Text("Error deleting task"),
          )),
        );
  }

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
          return const Center(child: Text('Empty!'));
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            // Transforma snapshot dos documentos em um map (array com keys e values).
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            // Faz 1 card para cada item do map data.
            return Column(
              children: [
                Slidable(
                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _deleteTaskItem(document.id),
                        backgroundColor: const Color.fromARGB(255, 234, 71, 62),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_forever,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 102, 102, 102),
                          blurRadius: 15.0,
                        ),
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          (data['tag'] == 'work') ? Icons.work : Icons.backpack,
                          size: 35,
                        ),
                        title: Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          data['description'],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        // Navigate to edit task screen.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTask(taskId: document.id, taskData: data),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
