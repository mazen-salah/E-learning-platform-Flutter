import 'package:flutter/material.dart';
import 'package:tit_for_tat/screens/lesson_screen.dart';
import 'package:tit_for_tat/screens/login_screen.dart';
import '../screens/test_screen.dart';
import '../screens/units_screen.dart';
import '../screens/home_page.dart';
import '../screens/voucher_generate.dart';
import 'widgets/category.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => const MyHomePage(),
  '/login': (context) => const LoginPage(),
  '/generateVoucher': (context) => const VoucherGeneratePage(),
  '/lessons': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final videoUrl = args['videoUrl'] as String;
    final lessonTitle = args['lessonTitle'] as String;
    final resources = args['resources'] as String;
    final testId = args['testId'] as String;
    return LessonScreen(
      videoUrl: videoUrl,
      lessonTitle: lessonTitle,
      resources: resources,
      testId: testId,
    );
  },
  '/test': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final title = args['title'] as String;
    final testId = args['testId'] as String;
    return TestScreen(
      title: title,
      testId: testId,
    );
  },
  '/units': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final grade = args['grade'] as String;
    final data = args['data'] as String;
    return UnitsScreen(
      grade: grade,
      data: data,
    );
  },
  '/category': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final grade = args['grade'] as String;
    final vocabData = args['vocabData'] as String;
    final grammarData = args['grammarData'] as String;

    return CategoryScreen(
      grade: grade,
      term1: vocabData,
      term2: grammarData,
    );
  },
};
