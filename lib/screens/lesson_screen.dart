import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tit_for_tat/shared/admin.dart';
import 'package:tit_for_tat/shared/color.dart';
import 'package:tit_for_tat/shared/widgets/link_button.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class LessonScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final String resources;
  final String testId;
  final String videoTitle;

  bool questionsAvailable = false;

  LessonScreen(
      {Key? key,
      required this.videoUrl,
      required this.lessonTitle,
      required this.resources,
      required this.testId,
      required this.videoTitle})
      : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tests = FirebaseFirestore.instance.collection('tests');
    final questions = tests.doc(widget.testId).collection('questions');

    questions.get().then((querySnapshot) {
      if (querySnapshot.size == 0) {
        debugPrint('No questions found.');
      } else {
        debugPrint('Found ${querySnapshot.size} questions.');
        setState(() {
          widget.questionsAvailable = true;
        });
      }
    }).catchError((error) {
      debugPrint('Failed to load questions: $error');
    });
    return YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${widget.lessonTitle.split(' ')[0]} ${widget.lessonTitle.split(' ')[1]}'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    const Divider(
                      thickness: 2,
                      color: Colors.white38,
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                        ),
                        child: Text(
                          widget.lessonTitle.split(' ')[2],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.videoTitle != '')
                  Text(
                    widget.videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: player,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Divider(thickness: 2, color: Colors.white38),
                ),
                if (widget.resources != '')
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'المرفقات',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        linkButton(
                            "${widget.lessonTitle.split(' ')[0]} ${widget.lessonTitle.split(' ')[1]}\n${widget.lessonTitle.split(' ')[2]}",
                            widget.resources,
                            Icons.book),
                      ],
                    ),
                  ),
                Expanded(child: Container()),
                if (widget.questionsAvailable || admin)
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black38,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))),
                      onPressed: () {
                        Navigator.pushNamed(context, '/test', arguments: {
                          'title': widget.lessonTitle,
                          'testId': widget.testId,
                        });
                      },
                      child: const Text('تمارين على الدرس')),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
  }
}
