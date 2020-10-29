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
        Downloaded(downloadedList: downloadedList),
        IsolateOne(downloadedList: downloadedList),
        IsolateTwo(downloadedList: downloadedList),
        IsolateThree(downloadedList: downloadedList),
      ],
    );
  }
}
