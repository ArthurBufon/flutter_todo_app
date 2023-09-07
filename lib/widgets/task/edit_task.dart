import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/models/task.dart';

class EditTask extends StatefulWidget {
  // Task data required in constructor.
  const EditTask({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  // TaskId
  final String taskId;

  // TaskData
  final Map<String, dynamic> taskData;

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  // Firestore instance.
  var db = FirebaseFirestore.instance;

  // Unique global key that identifies the Form Widget.
  final _formKey = GlobalKey<FormState>();

  var taskTitleController = TextEditingController();
  var taskDescController = TextEditingController();
  // Selected Tag.
  String? _selectedTag;

  // TagList.
  List<String> tagList = ['work', 'college'];

  // TaskData
  late Map<String, dynamic> taskData = widget.taskData;

  // TaskId
  late String taskId = widget.taskId;

  @override
  void initState() {
    taskTitleController.text = taskData['title'];
    taskDescController.text = taskData['description'];
    _selectedTag = taskData['tag'];
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    taskTitleController.dispose();
    taskDescController.dispose();
    super.dispose();
  }

  // Adds new task to database.
  void _updateTask({required taskId, required taskData}) {
    // Task Reference to document.
    final taskRef = db.collection('tasks').doc(taskId);

    taskRef.update(taskData).then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Color.fromARGB(255, 101, 225, 105),
              content: Text("Task updated successfully!"),
            )),
        onError: (e) =>
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Color.fromARGB(255, 241, 117, 117),
              content: Text("Error in updating data!"),
            )));

    // // Redirects back to home page.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 232, 255),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color.fromARGB(255, 174, 148, 222),
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
      body: SafeArea(
        child: Form(
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
                      'Editing Task',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Task name.
                    TextFormField(
                      controller: taskTitleController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 253, 241, 255),
                        border: OutlineInputBorder(),
                        labelText: 'Task',
                      ),
                      // Validation.
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length <= 1) {
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
                        filled: true,
                        fillColor: Color.fromARGB(255, 253, 241, 255),
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                      ),
                      // Validation.
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length <= 1) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Select Task Tag.
                    DropdownButtonFormField(
                      hint: const Text('Select the Tag'),
                      value: taskData['tag'].toString(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTag = value;
                        });
                        print(_selectedTag);
                      },
                      validator: (value) =>
                          value == null ? 'Please select the task tag' : null,
                      // Transform each tagList item in a DropdownMenuItem.
                      items: tagList.map((String val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              // Shows snackbar.
                              const SnackBar(
                                content: Text('Processing data...'),
                              ),
                            );
                            // Sends data to store on db.
                            final taskName = taskTitleController.text;
                            final taskDesc = taskDescController.text;
                            final taskTag = _selectedTag.toString();

                            // Generates json for task.
                            final taskData = <String, dynamic>{
                              "title": taskName,
                              "description": taskDesc,
                              "tag": taskTag,
                            };
                            _updateTask(taskId: taskId, taskData: taskData);
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            backgroundColor: const MaterialStatePropertyAll(
                              Color.fromARGB(255, 174, 148, 222),
                            )),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
