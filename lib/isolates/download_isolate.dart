import 'dart:io';
import 'dart:isolate';
import 'package:download_isolate/isolates/IsolateThree.dart';
import 'package:download_isolate/isolates/isolate_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadIsolate extends StatefulWidget {
  @override
  _DownloadIsolateState createState() => _DownloadIsolateState();
}

class _DownloadIsolateState extends State<DownloadIsolate> {
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
  static List<String> pdf = [
    'http://www.africau.edu/images/default/sample.pdf',
    'https://aktu.ac.in/pdf/ADF%20Guidelines.pdf',
    'https://aktu.ac.in/pdf/aip/AIP19-20_ShortlistedCandidates.pdf',
    'https://aktu.ac.in/pdf/EAP-AKTU.pdf',
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'https://books.goalkicker.com/PythonBook/PythonNotesForProfessionals.pdf'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Downloading...', style: TextStyle(fontSize: 25)),
        Text('Downloaded ${downloaded.length} / ${pdf.length}'),
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
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // RaisedButton(
            //   onPressed: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => NextPage()));
            //   },
            //   child: Text('NextPage'),
            // ),
            RaisedButton(
              onPressed: () async {
                var status = await Permission.storage.status;
                if (!status.isGranted) {
                  await Permission.storage.request();
                }
                _start1();
                setState(() {
                  downloading = true;
                });
              },
              child: Text('Download 1'),
            ),
            RaisedButton(
              onPressed: () {
                _stop();
                setState(() {
                  downloading = true;
                  downloaded = [];
                });
              },
              child: Text('Stop 1'),
            ),
            RaisedButton(
              onPressed: () {
                _pause();
              },
              child: _paused == true? Text('Play'):Text('Pause'),

            ),
          ],
        ),
        //Download2 & Download3 Button
        IsolateTwo(),

        IsolateThree(),

        // Pause and Stop Button

      ],
    );
  }

  void _start1() async {
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

      _message = data;

    });
  }

  static void _isolateHandler(ThreadParams threadParams) async {
    _download1(threadParams);
  }

  static _download1(ThreadParams threadParams) async {
    for (j = 0; j < pdf.length; j++) {
      String path;
      File file;
      HttpClient httpClient = new HttpClient();
      var response;
      var request = await httpClient.getUrl(Uri.parse(pdf.elementAt(j)));

      response = await request.close();
      if (response.statusCode == 200) {
        print('==================> Downloading <=============');
        String fileName = basename(pdf.elementAt(j));
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
