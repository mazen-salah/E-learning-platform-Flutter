import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

final DocumentReference _links =
    FirebaseFirestore.instance.collection('data').doc('links');

Padding linkButton(String label, String linkId, IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: ElevatedButton.icon(
      label: Text(
        label,
        style: GoogleFonts.roboto(fontSize: 15, color: Colors.white),
      ),
      onPressed: () {
        _links.get().then((value) {
          if (linkId.contains('http')) {
            launchUrl(Uri.parse(linkId));
          } else if (linkId == 'store') {
            Share.share(value[linkId].toString());
          } else {
            try {
              launchUrl(Uri.parse(value[linkId].toString()));
            } catch (e) {
              AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
              );
            }
          }
        });
      },
      icon: Icon(icon),
    ),
  );
}
