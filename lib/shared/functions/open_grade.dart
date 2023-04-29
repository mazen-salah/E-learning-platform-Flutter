import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<Object?> openGradeUnits(BuildContext context,
    AsyncSnapshot<QuerySnapshot<Object?>> snapshots, int index) {
  final doc = snapshots.data!.docs[index];
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  final grade = data.containsKey('name') ? data['name'] : null;
  final unitData = data.containsKey('data') ? data['data'] : null;

  return Navigator.pushNamed(
    context,
    '/units',
    arguments: {
      'grade': grade,
      'data': unitData,
    },
  );
}
