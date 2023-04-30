import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tit_for_tat/shared/admin.dart';
import '../../screens/add_unit.dart';
import '../widgets/error.dart';

StreamBuilder<QuerySnapshot<Object?>> streamCollection(
  CollectionReference<Object?> collection,
  void Function(BuildContext, AsyncSnapshot<QuerySnapshot<Object?>>, int)
      onPressed,
) {
  return StreamBuilder(
    stream: collection.snapshots(),
    builder: (context, snapshots) {
      debugPrint("\n\n\n\n\n\tSnapshots: $snapshots \n\n\n\n\n");

      if (snapshots.hasError) {
        error();
      } else if (snapshots.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      } else if (snapshots.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.error_outline_outlined,
                size: 40,
                color: Colors.white,
              ),
              Text(
                "No Data available",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ],
          ),
        );
      } else if (snapshots.hasData) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black38,
          ),
          child: ListView.builder(
            itemCount: snapshots.data?.docs.length,
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (admin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (snapshots.data!.docs[index]['name']
                            .toString()
                            .toLowerCase()
                            .contains('unit'))
                          IconButton(
                            color: Colors.white,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('تعديل'),
                                    content:
                                        const Text('هل تريد تعديل الوحده؟'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddUnit(
                                                  grade: collection.id,
                                                  data: collection.id,
                                                  unitId: snapshots
                                                      .data!.docs[index].id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('نعم')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('لا')),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        if (snapshots.data!.docs[index]['name']
                            .toString()
                            .toLowerCase()
                            .contains('unit'))
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('حذف'),
                                    content: const Text('هل تريد حذف الوحده؟'),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            collection
                                                .doc(snapshots
                                                    .data!.docs[index].id)
                                                .delete();
                                            if (snapshots
                                                .data!.docs[index]['name']
                                                .toString()
                                                .toLowerCase()
                                                .contains('unit')) {
                                              String id = snapshots.data!
                                                  .docs[index]['vocabTestId'];
                                              String id2 = snapshots.data!
                                                  .docs[index]['grammarTestId'];
                                              CollectionReference<Object?>
                                                  tests = FirebaseFirestore
                                                      .instance
                                                      .collection('tests');
                                              await tests
                                                  .doc(id)
                                                  .collection('questions')
                                                  .get()
                                                  .then((querySnapshot) {
                                                for (var doc
                                                    in querySnapshot.docs) {
                                                  doc.reference.delete();
                                                }
                                              });
                                              await tests
                                                  .doc(id2)
                                                  .collection('questions')
                                                  .get()
                                                  .then((querySnapshot) {
                                                for (var doc
                                                    in querySnapshot.docs) {
                                                  doc.reference.delete();
                                                }
                                              });
                                              await tests
                                                  .doc(id)
                                                  .delete()
                                                  .then((value) => debugPrint(
                                                      'Test Deleted'))
                                                  .catchError((error) => debugPrint(
                                                      'Failed to delete test: $error'));
                                              await tests
                                                  .doc(id2)
                                                  .delete()
                                                  .then((value) => debugPrint(
                                                      'Test Deleted'))
                                                  .catchError((error) => debugPrint(
                                                      'Failed to delete test: $error'));
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: const Text('نعم')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('لا')),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                          ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      onPressed: () {
                        onPressed(context, snapshots, index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        child: Text(
                          snapshots.data!.docs[index]['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains('unit')
                              ? 'Unit ${snapshots.data!.docs[index]['name'].toString().split(' ')[1]}'
                              : snapshots.data!.docs[index]['name'],
                          style: GoogleFonts.roboto(
                              fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    },
  );
}
