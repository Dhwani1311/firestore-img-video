import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() => runApp(MyPage());

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Network Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

    Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network('http://techslides.com/demos/sample-videos/small.mp4');
    await _videoPlayerController.initialize();
    // Wrapper on top of the videoPlayerController
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      looping: false,
      aspectRatio: 16 / 9,autoInitialize: true,
      autoPlay: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
    setState(() {

    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _videoPlayerController.dispose();
  //   _chewieController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Second Page")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                child: Image.network(
                  'https://imgsv.imaging.nikon.com/lineup/dslr/df/img/sample/img_01_l.jpg',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                child: _chewieController != null &&
                    _chewieController
                        .videoPlayerController.value.initialized
                    ? Chewie(
                  controller: _chewieController,
                ) :
                CircularProgressIndicator(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                child: _chewieController != null &&
                    _chewieController
                        .videoPlayerController.value.initialized
                    ? Chewie(
                  controller: _chewieController,
                ) :
                CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
