import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/color.dart';

import 'edit_question.dart';

class TestScreen extends StatefulWidget {
  final String testId;
  final String title;
  const TestScreen({Key? key, required this.testId, required this.title})
      : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  CollectionReference tests = FirebaseFirestore.instance.collection('tests');
  List<int?> selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    CollectionReference test = tests.doc(widget.testId).collection('questions');

    return Scaffold(
      floatingActionButton: Visibility(
        visible: admin,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionForm(
                      testId: widget.testId,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('${widget.title} Exercise'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: test.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.active &&
                    !snapshot.hasData) {
                  return const Center(child: Center(child: Text('No Data')));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (selectedIndexes.length <= index) {
                        selectedIndexes.add(null);
                      }
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data()! as Map<String, dynamic>;
                      List<dynamic> options = data['options'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: options[selectedIndexes[index] ?? 0] ==
                                      data['answer'] &&
                                  selectedIndexes[index] != null
                              ? Colors.green.withOpacity(0.5)
                              : myColor.withOpacity(0.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                color: Colors.white,
                                thickness: 2,
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Question ${index + 1}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                thickness: 2,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    data['text'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Choose:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black38,
                                ),
                                child: Column(
                                  children: [
                                    for (int i = 0; i < options.length; i++)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${i + 1} .',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              textAlign: TextAlign.start,
                                            ),
                                            const SizedBox(width: 10),
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: selectedIndexes[
                                                                index] ==
                                                            i &&
                                                        options[i] ==
                                                            data['answer']
                                                    ? Colors.green
                                                    : selectedIndexes[index] ==
                                                                i &&
                                                            options[i] !=
                                                                data['answer']
                                                        ? Colors.red
                                                        : Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedIndexes[index] = i;
                                                });

                                                if (options[i] ==
                                                    data['answer']) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Center(
                                                            child: Text(
                                                              'Correct !',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                          ),
                                                          content: Text(
                                                            data['correctMessage'] ==
                                                                    ''
                                                                ? 'Good!'
                                                                : data[
                                                                    'correctMessage']!,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        );
                                                      });
                                                } else {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Center(
                                                            child: Text(
                                                              'Wrong !',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                          content: Text(
                                                            data['incorrectMessage'] ==
                                                                    ''
                                                                ? 'Try again!'
                                                                : data[
                                                                    'incorrectMessage'],
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        );
                                                      });
                                                }
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  options[i],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (admin)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QuestionForm(
                                              questionId:
                                                  snapshot.data!.docs[index].id,
                                              testId: widget.testId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete Question'),
                                              content: const Text(
                                                  'Are you sure you want to delete this question?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    snapshot.data!.docs[index]
                                                        .reference
                                                        .delete();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}
