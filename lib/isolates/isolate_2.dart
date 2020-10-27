import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class IsolateTwo extends StatefulWidget {
  @override
  _IsolateTwoState createState() => _IsolateTwoState();
}

class _IsolateTwoState extends State<IsolateTwo> {
  static int j;
  Isolate _isolate;
  bool _running1 = false;
  bool _paused = false;
  String _message = '';
  ReceivePort _receivePort;
  Capability _capability;
  double per = 0;
  bool downloading = false;
  static List<String> downloaded = [];
  static List<String> image = [
    'https://ze-robot.com/dl/ul/ultraviolet-4k-wallpaper-2560%C3%971600.jpg',
    'https://i.imgur.com/sjvtlq0.jpg',
    'https://i.pinimg.com/originals/3b/8a/d2/3b8ad2c7b1be2caf24321c852103598a.jpg',
    'https://www.setaswall.com/wp-content/uploads/2017/03/Artistic-Landscape-4K-Wallpaper-3840x2160.jpg',
    'https://pixelz.cc/wp-content/uploads/2017/11/iron-man-3-tony-stark-uhd-4k-wallpaper.jpg',
    // 'https://www.chromethemer.com/download/hd-wallpapers/wicked-nature-4k-3840x2160.jpg',
    'https://www.wallpapertip.com/wmimgs/0-2393_macbook-pro-wallpaper-4k.jpg',
    'https://cdn.wccftech.com/wp-content/uploads/2020/02/windows-10-12-scaled.jpg'
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Downloading...', style: TextStyle(fontSize: 25)),
        Text('Downloaded ${downloaded.length} / ${image.length}'),
        Text(per.toString()),
        Text(
          _message,
          style: TextStyle(color: Colors.redAccent, fontSize: 20),
        ),
        //Downloaded items List
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
              child: Text('Download 2'),
            ),
            RaisedButton(
              onPressed: () async {

                _stop();
                setState(() {
                  downloading = true;
                  downloaded = [];
                });
              },
              child: Text('Stop 2'),
            ),
            RaisedButton(
              onPressed: () async {

                _pause();
                setState(() {
                  downloading = true;
                });
              },
              child: _paused == true? Text('Play'):Text('Pause'),
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
    _download1(threadParams);

  }
  static _download1(ThreadParams threadParams) async {
    for (j = 0; j < image.length; j++) {
      String path;
      File file;
      HttpClient httpClient = new HttpClient();
      var response;
      var request = await httpClient.getUrl(Uri.parse(image.elementAt(j)));

      response = await request.close();
      if (response.statusCode == 200) {
        print('==================> Downloading <=============');
        String fileName = basename(image.elementAt(j));
        print("=========> FILE NAME <=========" + fileName);
        var bytes = await consolidateHttpClientResponseBytes(response);
        new Directory('/storage/emulated/0/MFile')
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
