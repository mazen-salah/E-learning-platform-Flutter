import 'package:flutter/material.dart';
import 'package:tit_for_tat/shared/color.dart';
import 'package:tit_for_tat/shared/widgets/link_button.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final String resources;
  final String testId;

  const LessonScreen(
      {Key? key,
      required this.videoUrl,
      required this.lessonTitle,
      required this.resources,
      required this.testId})
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
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
                    'Documents',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  linkButton(widget.lessonTitle, widget.resources, Icons.book),
                ],
              ),
            ),
          Expanded(child: Container()),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black38,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)))),
              onPressed: () {
                Navigator.pushNamed(context, '/test', arguments: {
                  'title': widget.lessonTitle,
                  'testId': widget.testId,
                });
              },
              child: const Text('Exercises on this lesson')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
