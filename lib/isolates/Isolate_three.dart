import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import '../url_bloc.dart';

class IsolateThree extends StatefulWidget {
  final DownloadedList downloadedList;

  const IsolateThree({Key key, this.downloadedList}) : super(key: key);

  @override
  _IsolateThreeState createState() => _IsolateThreeState();
}

class _IsolateThreeState extends State<IsolateThree> {
  static int j;
  Isolate _isolate;
  bool _running1 = false;
  bool _paused = false;
  String _message = '';
  ReceivePort _receivePort;
  Capability _capability;
  double per = 0;
  bool downloading = false;
  static List<String> video = [
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-avi-file.avi',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mov-file.mov',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mpg-file.mpg',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-wmv-file.wmv',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-flv-file.flv',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-webm-file.webm',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mkv-file.mkv',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-ogv-file.ogv',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-3gp-file.3gp',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-3g2-file.3g2'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _message,
          style: TextStyle(color: Colors.redAccent, fontSize: 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              child: Text('Download 3'),
            ),
            RaisedButton(
              onPressed: () async {
                _stop();
                setState(() {
                  downloading = true;
                });
              },
              child: Text('Stop 3'),
            ),
            RaisedButton(
              onPressed: () async {
                _pause();
                setState(() {
                  downloading = true;
                });
              },
              child: _paused == true ? Text('Play') : Text('Pause'),
            ),
          ],
        ),
      ],
    );
  }

  void _start() async {
    if (_running1) {
      return;
    }
    setState(() {
      _running1 = true;
      _message = 'Starting...';
    });
    _receivePort = ReceivePort();

    ThreadParams threadParams = ThreadParams(_receivePort.sendPort);
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

  void _stop() {
    if (null != _isolate) {
      setState(() {
        _running1 = false;
        _paused = false;
      });
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  void _pause() {
    if (null != _isolate) {
      _paused ? _isolate.resume(_capability) : _capability = _isolate.pause();
      setState(() {
        _paused = !_paused;
        _message = 'Paused';
        print(_paused);
      });
    }
  }

  void _handleMessage(dynamic data) {
    setState(() {
      widget.downloadedList.downloadedListStreamController.sink.add(data);
      _message = data;
    });
  }

  static void _isolateHandler(ThreadParams threadParams) async {
    _download1(threadParams);
  }

  static _download1(ThreadParams threadParams) async {
    for (j = 0; j < video.length; j++) {
      String path;
      File file;
      HttpClient httpClient = new HttpClient();
      var response;
      var request = await httpClient.getUrl(Uri.parse(video.elementAt(j)));

      response = await request.close();
      if (response.statusCode == 200) {
        print('==================> Downloading <=============');
        String fileName = basename(video.elementAt(j));
        print("=========> FILE NAME <=========" + fileName);
        var bytes = await consolidateHttpClientResponseBytes(response);
        new Directory('/storage/emulated/0/MFile')
            .create()
            .then((Directory directory) async {
          path = directory.path;
          file = new File('$path/$fileName');
          file.writeAsBytes(bytes);
          threadParams.sendPort.send(fileName);
          return j;
        });
      } else {}
    }
  }
}

class ThreadParams {
  ThreadParams(this.sendPort);

  SendPort sendPort;
}
