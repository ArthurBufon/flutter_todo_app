import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key});

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  // Firestore instance.
  var db = FirebaseFirestore.instance;

  // Unique global key that identifies the Form Widget.
  final _formKey = GlobalKey<FormState>();

  final taskNameController = TextEditingController();
  final taskDescController = TextEditingController();
  // Selected Tag.
  String? _selectedTag;

  // TagList.
  List<String> tagList = ['work', 'college'];

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    taskNameController.dispose();
    taskDescController.dispose();
    super.dispose();
  }

  // Adds new task to database.
  void _saveTask({required taskName, required taskDesc, required taskTag}) {
    // Generates json for task.
    final task = <String, dynamic>{
      "title": taskName,
      "description": taskDesc,
      "tag": taskTag,
    };

    // Sends to firestore.
    db.collection('tasks').add(task).then((DocumentReference doc) =>
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color.fromARGB(255, 101, 225, 105),
          content: Text('Task successfully added!'),
        )));

    // Redirects back to home page.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 232, 255),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color.fromARGB(255, 102, 73, 154),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),

      // Creates a Form Widget that uses the unique _formKey generated above.
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          // Center widget.
          child: Center(
            // SingleChildScrollView prevents screen from overflowing.
            child: SingleChildScrollView(
              child: Column(
                // Form content goes inside here.
                children: <Widget>[
                  // Header.
                  const Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Task name.
                  TextFormField(
                    controller: taskNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Task',
                    ),
                    // Validation.
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length <= 1) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Task description.
                  TextFormField(
                    controller: taskDescController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                    // Validation.
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length <= 1) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Select Task Tag.
                  DropdownButtonFormField(
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value;
                      });
                    },
                    // Transform each tagList item in a DropdownMenuItem.
                    items: tagList.map((String val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Please select the task tag' : null,
                  ),
                  const SizedBox(height: 40),
                  // Submit button.
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validates form.
                        if (_formKey.currentState!.validate()) {
                          // Sends data to store on db.
                          final taskName = taskNameController.text;
                          final taskDesc = taskDescController.text;
                          final taskTag = _selectedTag;
                          _saveTask(
                              taskName: taskName,
                              taskDesc: taskDesc,
                              taskTag: taskTag);
                        }
                      },
                      // Submit Form.
                      style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
