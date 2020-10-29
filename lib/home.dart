import 'package:download_isolate/url_bloc.dart';
import 'package:flutter/material.dart';
import 'downloaded_list.dart';
import 'isolates/Isolate_three.dart';
import 'isolates/isolate_one.dart';
import 'isolates/isolate_two.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static DownloadedList downloadedList = DownloadedList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text('Isolate', style: TextStyle(fontSize: 20)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IsolateOne(downloadedList: downloadedList),
            IsolateTwo(downloadedList: downloadedList),
            IsolateThree(downloadedList: downloadedList),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 10),
          child: Divider(
            color: Colors.grey[800],
          ),
        ),
        Downloaded(downloadedList: downloadedList),
      ],
    );
  }
}
