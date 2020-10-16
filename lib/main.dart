import 'dart:io';
import 'dart:isolate';
import 'package:download_isolate/url%20_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'next+page.dart';

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
  static var j;
  Isolate _isolate;
  bool _running = false;
  bool _paused = false;
  String _message = '';
  ReceivePort _receivePort;
  Capability _capability;
  int i;
  var listItem;
  int lengthList;
  bool progress = false;
  DownloadUrl downloadUrl = DownloadUrl();
  static List<String> url = [
    'https://files.jotform.com/jotformpdfs/guest_05d8ff12a9e7c42b/202871741050044/10202870988350059/202871741050044.pdf?md5=iF_5neoIGzvWcPw0m3jupg&expires=1602656963',
  ];

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: x.height * 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

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
    // ThreadParams threadParams = ThreadParams(2000, _receivePort.sendPort);
    _isolate = await Isolate.spawn(_isolateHandler, _receivePort.sendPort);
    _receivePort.listen(_handleMessage, onDone: () {
      print('Done');
      setState(() {});
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
      _message = data;
    });
  }

  static void _isolateHandler(SendPort sendPort) async {
    _downloadFile(sendPort);
  }

  static _downloadFile(SendPort sendPort) async {
    for (j = 0; j < 100; j++) {
      for (var i = 0; i < url.length; i++) {
        String path;
        File file;
        HttpClient httpClient = new HttpClient();
        var request = await httpClient.getUrl(Uri.parse(url.elementAt(i)));
        var response = await request.close();
        if (response.statusCode == 200) {
          print('==================> Downloading <=============');
          var bytes = await consolidateHttpClientResponseBytes(response);
          new Directory('/storage/emulated/0/MFile')
              .create()
              .then((Directory directory) async {
            path = directory.path;
            file = new File('$path/$j.pdf');
            await file.writeAsBytes(bytes);
            print(j.toString());
            return j;
            // print(directory.path);
          });
        } else {
          String error = response.statusCode.toString();
          print('===============> Error <==============>>' + error);
        }
      }
    }
  }
}
