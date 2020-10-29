import 'package:download_isolate/url_bloc.dart';
import 'package:flutter/material.dart';

class Downloaded extends StatefulWidget {
  final DownloadedList downloadedList;

  const Downloaded({Key key, this.downloadedList}) : super(key: key);

  @override
  _DownloadedState createState() => _DownloadedState();
}

class _DownloadedState extends State<Downloaded> {
  List<String> downloaded = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: widget.downloadedList.downloadedListStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            downloaded.add(snapshot.data);
            print('=====================' + snapshot.data);
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: downloaded.length,
                itemBuilder: (BuildContext context, index) {
                  return Center(
                    child: Text(downloaded[index]),
                  );
                });
          } else {
            return Container();
          }
        });
  }
}
