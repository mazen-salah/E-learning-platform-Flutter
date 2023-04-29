import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String grade;
  final String vocabData;
  final String grammarData;
  const CategoryScreen(
      {Key? key,
      required this.grade,
      required this.vocabData,
      required this.grammarData})
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
                  arguments: {'grade': grade, 'data': vocabData});
            },
            child: const Text('Vocabulary')),
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
                  arguments: {'grade': grade, 'data': grammarData});
            },
            child: const Text('Grammar')),
      ],
    );
  }
}
