import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<Object?> openLesson(BuildContext context,
    AsyncSnapshot<QuerySnapshot<Object?>> snapshots, int index) {
  final doc = snapshots.data!.docs[index];
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  final videoUrl = data.containsKey('video') ? data['video'] : '';
  final lessonTitle = data.containsKey('name') ? data['name'] : 'Lesson';
  final resources = data.containsKey('resources') ? data['resources'] : '';
  final testId = data.containsKey('testId') ? data['testId'] : '';

  return Navigator.pushNamed(
    context,
    '/lessons',
    arguments: {
      'videoUrl': videoUrl,
      'lessonTitle': lessonTitle,
      'resources': resources,
      'testId': testId,
    },
  );
}
