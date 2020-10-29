import 'package:camera/camera.dart';
import 'package:download_isolate/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'camera/camera_view.dart';

// List<CameraDescription> cameras;
void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.last;
  // cameras = await availableCameras();
  runApp(MyApp(
    camera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key key, this.camera}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        camera1: camera,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera1;

  const MyHomePage({Key key, this.camera1}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: x.height * 1.0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Camera View
                CameraView(camera: widget.camera1,),
                //NextPage and Download Button
                HomePage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

