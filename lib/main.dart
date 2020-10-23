import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:download_isolate/url%20_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera.dart';
import 'next_page.dart';

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
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera1,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  static DownloadUrl downloadUrl = DownloadUrl();
  DownloadProgress downloadProgress = DownloadProgress();
  bool camStatus = false;
  static int j;
  Isolate _isolate;
  bool _running = false;
  bool _paused = false;
  String _message = '';
  ReceivePort _receivePort;
  Capability _capability;
  int i = 0;
  int k;
  var listItem;
  int lengthList;
  bool progress = false;
  double per = 0;
  bool downloading = false;
  static List<String> downloaded = [];
  static List<String> url = [
    // 'https://www.learningcontainer.com/download/sample-mp3-file/?wpdmdl=1676&refresh=5f91402cf1c901603354668',
    'http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_60fps_stereo_abl.mp4',
    'https://img.favpng.com/9/25/24/computer-icons-instagram-logo-sticker-png-favpng-LZmXr3KPyVbr8LkxNML458QV3_t.jpg',
    'https://static.videezy.com/system/protected/files/000/008/302/Dark_Haired_Girl_angry__what____1.mp4',
    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__340.jpg',
    // 'https://files.jotform.com/jotformpdfs/guest_05d8ff12a9e7c42b/202871741050044/10202870988350059/202871741050044.pdf?md5=iF_5neoIGzvWcPw0m3jupg&expires=1602656963',
    'https://aktu.ac.in/pdf/ADF%20Guidelines.pdf',
    'https://aktu.ac.in/pdf/aip/AIP19-20_ShortlistedCandidates.pdf',
    'https://aktu.ac.in/pdf/EAP-AKTU.pdf',
  ];

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: x.height * 1.0,
          child: Column(
            children: [
              Text('Downloading...', style: TextStyle(fontSize: 25)),
              Text('Downloaded ${downloaded.length} / ${url.length}'),
              Text(per.toString()),
              Text(
                _message,
                style: TextStyle(color: Colors.redAccent, fontSize: 20),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: downloaded.length,
                  itemBuilder: (BuildContext context, index) {
                    return Center(
                      child: Text(downloaded[index].toString()),
                    );
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => NextPage()));
                    },
                    child: Text('NextPage'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      var status = await Permission.storage.status;
                      if (!status.isGranted) {
                        await Permission.storage.request();
                      }
                      _start();
                      setState(() {
                        downloading = true;
                      });
                    },
                    child: Text('Download'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _pause();
                    },
                    child: Text('Pause'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _stop();
                      setState(() {
                        downloaded = [];
                      });
                    },
                    child: Text('Stop'),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 500,
                    width: 300,
                    child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // If the Future is complete, display the preview.
                          return CameraPreview(_controller);
                        } else {
                          // Otherwise, display a loading indicator.
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _start() async {
    if (_running) {
      return;
    }
    setState(() {
      _running = true;
      _message = 'Starting...';
    });
    _receivePort = ReceivePort();

    ThreadParams threadParams = ThreadParams(downloaded, _receivePort.sendPort);
    _isolate = await Isolate.spawn(
      _isolateHandler,
      threadParams,
    );
    _receivePort.listen(_handleMessage, onDone: () {
      print('Done');
      setState(() {
        _message = 'Stopped Downloading';
      });
    });
  }

  void _pause() {
    if (null != _isolate) {
      _paused ? _isolate.resume(_capability) : _capability = _isolate.pause();
      setState(() {
        _paused = !_paused;
        print(_paused);
      });
    }
  }

  void _stop() {
    if (null != _isolate) {
      setState(() {
        _running = false;
        _paused = false;
      });
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  void _handleMessage(dynamic data) {
    setState(() {
      downloaded.add(data);
      // k = i + 1;
      // String fileName = basename(url.elementAt(j));
      // downloaded.add(fileName);
      _message = data;
      // i = k;
      // downloadUrl.urlStreamController.sink.add(downloaded);
      // _message = data.toString();
    });
  }

  static void _isolateHandler(ThreadParams threadParams) async {
    _downloadFile(threadParams);
  }

  static _downloadFile(ThreadParams threadParams) async {
    for (j = 0; j < url.length; j++) {
      String path;
      File file;
      HttpClient httpClient = new HttpClient();
      var response;
      var request = await httpClient.getUrl(Uri.parse(url.elementAt(j)));

      response = await request.close();
      if (response.statusCode == 200) {
        print('==================> Downloading <=============');
        String fileName = basename(url.elementAt(j));
        print("=========> FILE NAME <=========" + fileName);
        var bytes = await consolidateHttpClientResponseBytes(response);
        new Directory('/storage/emulated/0/MmFile')
            .create()
            .then((Directory directory) async {
          path = directory.path;
          file = new File('$path/$fileName');
          file.writeAsBytes(bytes);
          downloaded.add(fileName);
          threadParams.sendPort.send(fileName);
          return j;
        });
      } else {}
    }
  }

  Future<void> _getImage(ImageSource source) async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {});
    }
  }
}

class ThreadParams {
  ThreadParams(this.downloaded, this.sendPort);

  List<String> downloaded;
  SendPort sendPort;
}
