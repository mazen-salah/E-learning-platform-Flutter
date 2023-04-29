import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/functions/open_lesson.dart';
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
            Expanded(
              child: streamCollection(
                gradeCollection,
                (context, snapshots, index) {
                  openLesson(context, snapshots, index);
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
