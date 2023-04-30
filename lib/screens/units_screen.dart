import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/color.dart';
import '../shared/functions/stream_collection.dart';
import 'add_unit.dart';

class UnitsScreen extends StatefulWidget {
  final String grade;
  final String data;
  const UnitsScreen({super.key, required this.grade, required this.data});
  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
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
        body: Column(
          children: [
            const Divider(
              color: Colors.white38,
              thickness: 2,
            ),
            Container(
              color: myColor.withOpacity(0.5),
              child: Center(
                child: Text(
                  "Units",
                  style:
                      GoogleFonts.sacramento(color: Colors.white, fontSize: 45),
                ),
              ),
            ),
            const Divider(
              color: Colors.white38,
              thickness: 2,
            ),
            Expanded(
              child: streamCollection(
                gradeCollection,
                (context, snapshots, index) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: Center(
                                child:
                                    Text(snapshots.data?.docs[index]['name'])),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (snapshots.data?.docs[index]
                                            ['grammarVideo'] ==
                                        '' &&
                                    snapshots.data?.docs[index]['vocabVideo'] ==
                                        '')
                                  const Text(
                                      'There are no lessons for this unit yet.'),
                                if (snapshots.data?.docs[index]
                                            ['grammarVideo'] !=
                                        '' &&
                                    snapshots.data?.docs[index]['vocabVideo'] !=
                                        '')
                                  const Text('Choose a lesson type: '),
                                if (snapshots.data?.docs[index]['vocabVideo'] !=
                                    '')
                                  OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blueGrey[900],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/lessons',
                                          arguments: {
                                            'videoUrl': snapshots.data
                                                ?.docs[index]['vocabVideo'],
                                            'lessonTitle': snapshots
                                                    .data?.docs[index]['name'] +
                                                ' Vocabulary',
                                            'resources': snapshots.data
                                                ?.docs[index]['vocabResources'],
                                            'testId': snapshots.data
                                                ?.docs[index]['vocabTestId'],
                                          },
                                        );
                                      },
                                      child: const Text('Vocabulary')),
                                if (snapshots.data?.docs[index]
                                        ['grammarVideo'] !=
                                    '')
                                  OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blueGrey[900],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/lessons',
                                          arguments: {
                                            'videoUrl': snapshots.data
                                                ?.docs[index]['grammarVideo'],
                                            'lessonTitle': snapshots
                                                    .data?.docs[index]['name'] +
                                                ' Grammar',
                                            'resources':
                                                snapshots.data?.docs[index]
                                                    ['grammarResources'],
                                            'testId': snapshots.data
                                                ?.docs[index]['grammarTestId'],
                                          },
                                        );
                                      },
                                      child: const Text('Grammar')),
                              ],
                            ));
                      });
                },
              ),
            ),
            if (admin)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddUnit(
                              grade: widget.grade,
                              data: widget.data,
                            );
                          },
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
          ],
        ));
  }
}
