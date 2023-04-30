import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tit_for_tat/screens/home_page.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/color.dart';
import 'package:tit_for_tat/shared/routes.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

List<dynamic> adminArray = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  adminArray = await FirebaseFirestore.instance
      .collection('admin')
      .doc('admin')
      .get()
      .then((value) => value.data()!['admin']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _walletCollection =
      FirebaseFirestore.instance.collection('wallets');
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  MyApp({Key? key}) : super(key: key);

  Future<void> _initializeWallet(String uid) async {
    final walletDoc = _walletCollection.doc(uid);
    final coursesDoc = _userCollection.doc(uid);
    final courseSnapshot = await coursesDoc.get();
    final walletSnapshot = await walletDoc.get();

    if (!walletSnapshot.exists) {
      await walletDoc.set({
        'balance': 0,
      });
    }

    if (!courseSnapshot.exists) {
      await coursesDoc.set({
        'courses': [false, false, false],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      theme: ThemeData(
        primarySwatch: myColor,
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            _initializeWallet(snapshot.data!.uid);

            if (adminArray.contains(snapshot.data!.uid)) {
              admin = true;
            }
            return const MyHomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
