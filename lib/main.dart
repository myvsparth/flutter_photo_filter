import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo_filter/camera_page.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _imagePath;
  String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Photo Filter'),
      ),
      body: Stack(
        children: <Widget>[
          _imagePath != null
              ? capturedImageWidget(_imagePath)
              : noImageWidget(),
          fabWidget(),
        ],
      ),
    );
  }

  Widget noImageWidget() {
    return SizedBox.expand(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Icon(
            Icons.image,
            color: Colors.grey,
          ),
          width: 60.0,
          height: 60.0,
        ),
        Container(
          margin: EdgeInsets.only(top: 8.0),
          child: Text(
            'No Image Captured',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    ));
  }

  Widget capturedImageWidget(String imagePath) {
    return SizedBox.expand(
      child: Image.file(File(
        imagePath,
      )),
    );
  }

  Widget fabWidget() {
    return Positioned(
      bottom: 30.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: openCamera,
        child: Icon(
          Icons.photo_camera,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future openCamera() async {
    availableCameras().then((cameras) async {
      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPage(cameras),
        ),
      );
      setState(() {
        _imagePath = imagePath;
      });
      var imageFile = File(imagePath);
      fileName = path.basename(imageFile.path);
      var image = imageLib.decodeImage(imageFile.readAsBytesSync());
      image = imageLib.copyResize(image, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Photo Filter Example"),
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );
      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
          _imagePath = imageFile.path;
        });
      }
    });
  }
}
