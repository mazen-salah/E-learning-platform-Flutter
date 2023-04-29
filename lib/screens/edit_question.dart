import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionForm extends StatefulWidget {
  final String testId;
  final String? questionId;
  final String? initialQuestion;
  final String? initialCorrectMessage;
  final String? initialIncorrectMessage;
  final List<String>? initialOptions;
  final String? initialAnswer;

  const QuestionForm({
    super.key,
    required this.testId,
    this.questionId,
    this.initialQuestion,
    this.initialCorrectMessage,
    this.initialIncorrectMessage,
    this.initialOptions,
    this.initialAnswer,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textController = TextEditingController();
  final _correctMessageController = TextEditingController();
  final _incorrectMessageController = TextEditingController();
  final _answerController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _textController.dispose();
    _correctMessageController.dispose();
    _incorrectMessageController.dispose();
    _answerController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    if (widget.questionId != null) {
      _getQuestion();
    } else {
      _textController.text = widget.initialQuestion ?? '';
      _correctMessageController.text = widget.initialCorrectMessage ?? '';
      _incorrectMessageController.text = widget.initialIncorrectMessage ?? '';
      _answerController.text = widget.initialAnswer ?? '';
      _option1Controller.text = widget.initialOptions?[0] ?? '';
      _option2Controller.text = widget.initialOptions?[1] ?? '';
      _option3Controller.text = widget.initialOptions?[2] ?? '';
      _option4Controller.text = widget.initialOptions?[3] ?? '';
    }
  }

  Future<void> _getQuestion() async {
    setState(() {
      _isLoading = true;
    });

    final question = await FirebaseFirestore.instance
        .collection('tests')
        .doc(widget.testId)
        .collection('questions')
        .doc(widget.questionId)
        .get();

    setState(() {
      _textController.text = question['text'];
      _correctMessageController.text = question['correctMessage'];
      _incorrectMessageController.text = question['incorrectMessage'];
      _answerController.text = question['answer'];
      _option1Controller.text = question['options'][0];
      _option2Controller.text = question['options'][1];
      _option3Controller.text = question['options'][2];
      _option4Controller.text = question['options'][3];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
            Text(widget.questionId == null ? 'Add Question' : 'Edit Question'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter a question';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _option1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Option 1',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _option2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Option 2',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _option3Controller,
                        decoration: const InputDecoration(
                          labelText: 'Option 3',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _option4Controller,
                        decoration: const InputDecoration(
                          labelText: 'Option 4',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _answerController,
                        decoration: const InputDecoration(
                          labelText: 'Correct answer',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Please enter the correct answer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _correctMessageController,
                        decoration: const InputDecoration(
                          labelText: 'Correct message',
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _incorrectMessageController,
                        decoration: const InputDecoration(
                          labelText: 'Incorrect message',
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            _saveQuestion(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _saveQuestion(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final options = [
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ];

      try {
        final questionData = {
          'text': _textController.text.trim(),
          'options': options,
          'answer': _answerController.text.trim(),
          'correctMessage': _correctMessageController.text.trim(),
          'incorrectMessage': _incorrectMessageController.text.trim(),
        };

        if (widget.questionId == null) {
          // add question
          await FirebaseFirestore.instance
              .collection('tests')
              .doc(widget.testId)
              .collection('questions')
              .add(questionData);
        } else {
          // update question
          await FirebaseFirestore.instance
              .collection('tests')
              .doc(widget.testId)
              .collection('questions')
              .doc(widget.questionId)
              .update(questionData);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }
}
