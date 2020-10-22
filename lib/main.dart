import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:download_isolate/url%20_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'next_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static DownloadUrl downloadUrl = DownloadUrl();
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
              Text('Downloading...',style:  TextStyle(fontSize: 25)),
              Text('Downloaded ${downloaded.length} / ${url.length}'),
              Text(_message, style:  TextStyle(color: Colors.redAccent, fontSize: 20),),
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
                    },
                    child: Text('Stop'),
                  ),

                ],
              )
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
        print("=========> FILE NAME <========="+fileName);
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
}

class ThreadParams {
  ThreadParams(this.downloaded, this.sendPort);
  List<String> downloaded;
  SendPort sendPort;
}
