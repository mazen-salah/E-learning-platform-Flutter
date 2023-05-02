import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddUnit extends StatefulWidget {
  final String grade;
  final String data;
  final String? unitId;

  const AddUnit({
    Key? key,
    required this.grade,
    required this.data,
    this.unitId,
  }) : super(key: key);

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  final _formKey = GlobalKey<FormState>();
  final _lessonTitleController = TextEditingController();
  final _vocabVideoUrlController = TextEditingController();
  final _grammarVideoUrlController = TextEditingController();
  final _vocabResourcesController = TextEditingController();
  final _grammarResourcesController = TextEditingController();
  final _vocabVideoTitleController = TextEditingController();
  final _grammarVideoTitleController = TextEditingController();

  bool get _isEditing => widget.unitId != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _loadUnitData();
    }
  }

  @override
  void dispose() {
    _lessonTitleController.dispose();
    _vocabVideoUrlController.dispose();
    _vocabResourcesController.dispose();
    _grammarVideoUrlController.dispose();
    _grammarResourcesController.dispose();
    _vocabVideoTitleController.dispose();
    _grammarVideoTitleController.dispose();
    super.dispose();
  }

  void _loadUnitData() async {
    debugPrint(widget.data);
    final unitSnapshot = await FirebaseFirestore.instance
        .collection(widget.data)
        .doc(widget.unitId)
        .get();
    debugPrint(widget.unitId);

    if (unitSnapshot.exists && unitSnapshot.data() != null) {
      final unitData = unitSnapshot.data()!;

      _lessonTitleController.text = unitData['name'] ?? '';
      _vocabVideoUrlController.text = unitData['vocabVideo'] ?? '';
      _vocabResourcesController.text = unitData['vocabResources'] ?? '';
      _grammarVideoUrlController.text = unitData['grammarVideo'] ?? '';
      _grammarResourcesController.text = unitData['grammarResources'] ?? '';
      _vocabVideoTitleController.text = unitData['vocabVideoTitle'] ?? '';
      _grammarVideoTitleController.text = unitData['grammarVideoTitle'] ?? '';
    } else {
      debugPrint('Error: Unit snapshot does not exist or has no data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference gradeCollection =
        FirebaseFirestore.instance.collection(widget.data);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Unit' : 'Add Unit'),
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
          child: SingleChildScrollView(
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
                        value.split(' ').length < 2) {
                      return 'Please enter a lesson title with at least 2 words \n[ex: Unit X ] ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _vocabVideoTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Vocabulary Video Title',
                  ),
                ),
                TextFormField(
                  controller: _vocabVideoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Vocabulary Video URL',
                  ),
                ),
                TextFormField(
                  controller: _vocabResourcesController,
                  decoration: const InputDecoration(
                    labelText: 'Vocabulary Resources',
                  ),
                ),
                TextFormField(
                  controller: _grammarVideoTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Grammar Video Title',
                  ),
                ),
                TextFormField(
                  controller: _grammarVideoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Grammar Video URL',
                  ),
                ),
                TextFormField(
                  controller: _grammarResourcesController,
                  decoration: const InputDecoration(
                    labelText: 'Grammar Resources',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        DateTime now = DateTime.now();
                        String formattedDate =
                            '${now.day}-${now.month}-${now.year}-${now.hour}-${now.minute}-${now.second}';
                        final unitData = {
                          'name': _lessonTitleController.text,
                          'vocabVideo': _vocabVideoUrlController.text,
                          'vocabResources': _vocabResourcesController.text,
                          'grammarVideo': _grammarVideoUrlController.text,
                          'grammarResources': _grammarResourcesController.text,
                          'grammarVideoTitle':
                              _grammarVideoTitleController.text,
                          'vocabVideoTitle': _vocabVideoTitleController.text,
                          'vocabTestId':
                              '${_lessonTitleController.text.replaceAll(' ', '-')}-vocab-test-$formattedDate',
                          'grammarTestId':
                              '${_lessonTitleController.text.replaceAll(' ', '-')}-grammar-test-$formattedDate',
                        };

                        if (_isEditing) {
                          await gradeCollection
                              .doc(widget.unitId)
                              .update(unitData);
                        } else {
                          final unitsSnapshot = await gradeCollection.get();
                          final unitsLength = unitsSnapshot.docs.length + 1;
                          await gradeCollection
                              .doc(
                                  '$unitsLength-${_lessonTitleController.text.replaceAll(' ', '-').toLowerCase()}')
                              .set(unitData);
                        }

                        Navigator.of(_formKey.currentContext!).pop();
                      }
                    },
                    child: Text(_isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
