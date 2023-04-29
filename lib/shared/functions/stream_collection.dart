import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tit_for_tat/shared/admin.dart';
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
      } else if (snapshots.connectionState == ConnectionState.active &&
          !snapshots.hasData) {
        return const Center(
          child: Text("No Data available"),
        );
      } else {
        return ListView.builder(
          itemCount: snapshots.data?.docs.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (admin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('تعديل'),
                                content: TextField(
                                  controller: TextEditingController(
                                    text: snapshots.data!.docs[index]['name'],
                                  ),
                                  onChanged: (value) {
                                    collection
                                        .doc(snapshots.data!.docs[index].id)
                                        .update({'name': value});
                                  },
                                ),
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
                                        onPressed: () {
                                          collection
                                              .doc(snapshots
                                                  .data!.docs[index].id)
                                              .delete();
                                          if (snapshots
                                              .data!.docs[index]['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains('unit')) {
                                            String id = snapshots
                                                .data!.docs[index]['testId'];
                                            FirebaseFirestore.instance
                                                .collection('tests')
                                                .doc(id)
                                                .delete();
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
