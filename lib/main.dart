
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api_image/secondPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image/Video',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "Image and video Player",
            ),
          ),
        ),
        body: MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {

  MyForm({
    Key key,
  }) : super(key: key);

  @override
  _MyFormState createState() => _MyFormState();

}

class _MyFormState extends State<MyForm> {
  PickedFile _image;
  File _video;
  ChewieController _chewieController;

  final ImagePicker imagePicker = ImagePicker();
  VideoPlayerController _videoPlayerController1;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.asset('video/download.mp4');
    await _videoPlayerController1.initialize();
    // Wrapper on top of the videoPlayerController
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      // // Prepare the video to be played and display the first frame
      // autoInitialize: true,
      looping: false,
      aspectRatio: 2/3,
      autoPlay: false,
      // Errors can occur for example when trying to play a video
      // from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.black38,
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            File(_image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50
                              )),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[700],
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                  child: Text('Upload image'),
                  onPressed: () {
                    uploadFile(_image);
                  }),
            ),
              Padding(
              padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
              child: _chewieController != null &&
         _chewieController
            .videoPlayerController.value.initialized
          ? Chewie(
              controller: _chewieController,
              ) : Text('Loading'),
              ),
                  RaisedButton(
                    onPressed: () {
                      _showVideo(context);
                    },
                    child: Text("Pick Video"),
                  ),
                Padding(
                padding: EdgeInsets.all( 10),
                child: RaisedButton(
                child: Text('Upload Video'),
                onPressed: () {
                uploadVideo(_video);
                }
                ),
                ),
            Padding(
              padding: EdgeInsets.all( 10),
              child: RaisedButton(
                  child: Text('Network'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPage()),
                    );
                  }
              ),
            ),],
        ),
      ),

    );
  }

  Future<firebase_storage.UploadTask> uploadFile(PickedFile file) async {
    if (file == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("No file was selected")));
      return null;
    }

    firebase_storage.UploadTask uploadTask;
    // Create a Reference to the file
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child("/${DateTime.now().millisecondsSinceEpoch}image.jpeg");
        //child('/images.jpeg');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': _image.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);

    } else {
      uploadTask = ref.putFile(File(_image.path), metadata);

    }

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("File successfully added")));

    return Future.value(uploadTask);
  }

  Future<firebase_storage.UploadTask> uploadVideo(File file)async {
    if (file == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("No file was selected")));
      return null;
    }
      firebase_storage.UploadTask uploadTask;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("/${DateTime.now().millisecondsSinceEpoch}video.mp4");

      final metadata = firebase_storage.SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {'picked-file-path': _video.path});

      if (kIsWeb) {
        uploadTask = ref.putData(await file.readAsBytes(), metadata);

      } else {
        uploadTask = ref.putFile(File(_video.path), metadata);

    }

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("File successfully added")));

    return Future.value(uploadTask);
  }

  _imgFromCamera() async {
    var image = await imagePicker.getImage(
        source: ImageSource.camera,
       imageQuality: 50
    );
    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    PickedFile image = await imagePicker.getImage(
        source: ImageSource.gallery,
        );
    setState(() {
      _image = image;
    });
  }

  _videoFromCamera() async {
    PickedFile video = await imagePicker.getVideo(
      source: ImageSource.camera,
    );
    _video = File(video.path);
    _videoPlayerController1 = VideoPlayerController.file(_video);
  }

  _videoFromGallery() async {
    PickedFile video = await imagePicker.getVideo(
      source: ImageSource.gallery,
    );
    _video = File(video.path);
    _videoPlayerController1 = VideoPlayerController.file(_video);
    await _videoPlayerController1.initialize();
    // Wrapper on top of the videoPlayerController
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      // // Prepare the video to be played and display the first frame
      // autoInitialize: true,
      looping: false,
      aspectRatio: 2/3,
      autoPlay: false,

      // Errors can occur for example when trying to play a video
      // from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );setState(() {

    });
  }

  void _showVideo(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        _videoFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _videoFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
