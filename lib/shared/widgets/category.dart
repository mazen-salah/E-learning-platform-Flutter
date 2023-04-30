import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String grade;
  final String term1;
  final String term2;
  const CategoryScreen(
      {Key? key, required this.grade, required this.term1, required this.term2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/units',
                  arguments: {'grade': grade, 'data': term1});
            },
            child: const Text('الترم الأول')),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/units',
                  arguments: {'grade': grade, 'data': term2});
            },
            child: const Text('الترم الثاني')),
      ],
    );
  }
}
