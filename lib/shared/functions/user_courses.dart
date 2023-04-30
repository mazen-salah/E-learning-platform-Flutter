import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<bool>> getUserCourses(String userId) async {
  final userData = await _firestore.collection('users').doc(userId).get();
  if (!userData.exists) {
    return [];
  }
  final courses = userData.data()!['courses'] as List<dynamic>;

  return courses.map<bool>((course) => course as bool).toList();
}

// Update the courses array for a user
Future<void> updateUserCourses(String userId, List<bool> courses) async {
  await _firestore.collection('users').doc(userId).update({
    'courses': courses,
  });
}
