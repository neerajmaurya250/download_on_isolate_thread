import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import '../url_bloc.dart';

class IsolateOne extends StatefulWidget {
  final DownloadedList downloadedList;

  const IsolateOne({Key key, this.downloadedList}) : super(key: key);

  @override
  _IsolateOneState createState() => _IsolateOneState();
}

class _IsolateOneState extends State<IsolateOne> {
  static int j;
  Isolate _isolate;
  bool _running1 = false;
  bool _paused = false;
  ReceivePort _receivePort;
  Capability _capability;
  double per = 0;
  bool downloading = false;
  bool paused = false;
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
        // Text(
        //   _message,
        //   style: TextStyle(color: Colors.redAccent, fontSize: 20),
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: FloatingActionButton(
                  backgroundColor:
                      downloading == true ? Colors.green : Colors.blue,
                  child: Column(
                    children: [
                      Text('1'),
                      Icon(Icons.download_rounded),
                    ],
                  ),
                  onPressed: () async {
                    var status = await Permission.storage.status;
                    if (!status.isGranted) {
                      await Permission.storage.request();
                    }
                    _start1();
                    setState(() {
                      downloading = true;
                    });
                  }),
            ),
            Row(
              children: [
                IconButton(
                    icon: Icon(
                      downloading == true
                          ? Icons.stop_outlined
                          : Icons.stop_rounded,
                      color: Colors.red,
                      size: 33,
                    ),
                    onPressed: () {
                      _stop();
                      setState(() {
                        downloading = false;
                        paused = false;
                      });
                    }),
                IconButton(
                    icon: Icon(
                      paused == true
                          ? Icons.play_arrow_rounded
                          : Icons.pause_circle_filled_rounded,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _pause();
                      setState(() {
                        if (downloading == true) {
                          paused = !paused;
                        }
                      });
                    }),
              ],
            )
          ],
        ),
      ],
    );
  }

  void _start1() async {
    if (_running1) {
      return;
    }
    setState(() {
      _running1 = true;
    });
    _receivePort = ReceivePort();

    ThreadParams threadParams = ThreadParams(_receivePort.sendPort);
    _isolate = await Isolate.spawn(
      _isolateHandler,
      threadParams,
    );
    _receivePort.listen(_handleMessage, onDone: () {
      print('Done');
      setState(() {});
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

        print(_paused);
      });
    }
  }

  void _handleMessage(dynamic data) {
    setState(() {
      widget.downloadedList.downloadedListStreamController.sink.add(data);
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
