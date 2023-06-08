import 'package:flutter/material.dart';

Center error() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Can\'t connect to the database, please check your internet connection and try again.',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 10),
        Icon(
          Icons.wifi_off,
          color: Colors.white,
          size: 50,
        ),
      ],
    ),
  );
}
