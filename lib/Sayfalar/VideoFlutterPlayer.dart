import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFlutterPlayer extends StatefulWidget {
  final String url;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  VideoFlutterPlayer(
      {required this.url, required this.floatingActionButtonLocation});

  @override
  _VideoFlutterPlayerState createState() => _VideoFlutterPlayerState(
      url: url, floatingActionButtonLocation: floatingActionButtonLocation);
}

class _VideoFlutterPlayerState extends State<VideoFlutterPlayer> {
  final String url;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  _VideoFlutterPlayerState(
      {required this.url, required this.floatingActionButtonLocation});

  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          child: Container(
            child: _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : Container(),
          ),
        ),
      ),
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        mini: true,
        backgroundColor: Colors.indigo[400],
        onPressed: () {
          setState(() {
            _controller!.value.isPlaying
                ? _controller!.pause()
                : _controller!.play();
            if (_controller!.value.duration == _controller!.value.position) {
              _controller!.value.isPlaying == false;
            }
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  /*kontrol() {
    if () {
      _controller!.value.isPlaying == false;
    }
  }*/

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}
