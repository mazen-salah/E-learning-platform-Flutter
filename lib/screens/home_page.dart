// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/functions/user_courses.dart';
import 'package:tit_for_tat/screens/voucher_redeem.dart';
import 'package:tit_for_tat/shared/widgets/category.dart';
import '../shared/functions/stream_collection.dart';
import '../shared/widgets/link_button.dart';

List<bool> courses = [];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _grades =
      FirebaseFirestore.instance.collection('grades');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int?> getWalletBalance() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final walletData =
        await _firestore.collection('wallets').doc(user.uid).get();
    if (!walletData.exists) {
      return null;
    }
    return walletData.data()?['balance'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              final FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
            },
            icon: const Icon(Icons.logout)),
        actions: [
          TextButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.wallet,
                  color: Colors.white,
                ),
                Text("Wallet", style: TextStyle(color: Colors.white)),
              ],
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const VoucherRedeemPage();
              }));
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
              if (FirebaseAuth.instance.currentUser != null)
                Text(
                  'Welcome ${FirebaseAuth.instance.currentUser!.displayName}',
                  style: GoogleFonts.sacramento(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: streamCollection(
                  _grades,
                  (context, snapshots, index) async {
                    await getUserCourses(FirebaseAuth.instance.currentUser!.uid)
                        .then((value) {
                      courses = value;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        debugPrint(courses.toString());
                        if (courses[index] == true) {
                          return AlertDialog(
                            title: Text(
                              snapshots.data?.docs[index]['name'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 30,
                              ),
                            ),
                            content: CategoryScreen(
                              grade: snapshots.data?.docs[index]['name'],
                              term1: snapshots.data?.docs[index]['term1'],
                              term2: snapshots.data?.docs[index]['term2'],
                            ),
                          );
                        }

                        return AlertDialog(
                          title: Text(
                            snapshots.data?.docs[index]['name'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 30,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'برجاء شراء الكورس اولا',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'سعر الكورس: ${snapshots.data?.docs[index]['price']} جنيه',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final user = _auth.currentUser;
                                if (user == null) {
                                  return;
                                }
                                final userData = await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                if (!userData.exists) {
                                  return;
                                }
                                final walletData = await _firestore
                                    .collection('wallets')
                                    .doc(user.uid)
                                    .get();
                                if (!walletData.exists) {
                                  return;
                                }
                                final walletBalance =
                                    walletData.data()?['balance'] ?? 0;
                                final coursePrice =
                                    snapshots.data?.docs[index]['price'] ?? 0;
                                if (walletBalance < coursePrice) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Error',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 30, color: Colors.red),
                                        ),
                                        content: const Text(
                                            'لا يوجد رصيد كافي في المحفظة برجاء شحن المحفظة و المحاولة مرة اخري',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20)),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const VoucherRedeemPage();
                                                    },
                                                  ),
                                                );
                                              },
                                              child: const Text('Ok')),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }
                                final courses = userData.data()?['courses']
                                    as List<dynamic>;
                                courses[index] = true;
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'courses': courses,
                                });
                                await _firestore
                                    .collection('wallets')
                                    .doc(user.uid)
                                    .update(
                                  {
                                    'balance': walletBalance - coursePrice,
                                  },
                                );
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Success',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 30,
                                              color: Colors.green),
                                        ),
                                        content: const Text(
                                            'تم شراء الكورس بنجاح',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20)),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Ok')),
                                        ],
                                      );
                                    });
                              },
                              child: const Text('Buy'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              if (admin)
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/generateVoucher');
                    },
                    icon: const Icon(Icons.monetization_on),
                    label: const Text('Generate Voucher')),
              linkButton('Telegram Channel', 'telegram', Icons.telegram),
              linkButton('Share app', 'store', Icons.share),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
