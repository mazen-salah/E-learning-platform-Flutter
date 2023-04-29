import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddUnit extends StatefulWidget {
  final String grade;
  final String data;
  const AddUnit({super.key, required this.grade, required this.data});

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  final _formKey = GlobalKey<FormState>();
  final _lessonTitleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _resourcesController = TextEditingController();

  @override
  void dispose() {
    _lessonTitleController.dispose();
    _videoUrlController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference gradeCollection =
        FirebaseFirestore.instance.collection(widget.data);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _lessonTitleController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Title',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.split(' ').length < 3) {
                    return 'Please enter a lesson title with at least 3 words \n[ex: Unit X Vocabulary or Unit X Grammar] ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a video URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _resourcesController,
                decoration: const InputDecoration(
                  labelText: 'Resources',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String docId = _lessonTitleController.text
                      .replaceAll(' ', '-')
                      .toLowerCase();
                  DateTime now = DateTime.now();
                  String date =
                      '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}';
                  String testId = '$docId-$date';

                  if (_formKey.currentState!.validate()) {
                    gradeCollection.doc(docId).set({
                      'name': _lessonTitleController.text,
                      'video': _videoUrlController.text,
                      'resources': _resourcesController.text,
                      'testId': testId,
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
