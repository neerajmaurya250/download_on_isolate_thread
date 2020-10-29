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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 8),
                      child: Text('Downloaded',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                    ),
                    FlatButton(onPressed: (){
                      setState(() {
                        downloaded = [];
                      });
                    }, child: Text('clear list'))
                ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: downloaded.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(

                            color: Colors.grey[300],

                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.done_outline_rounded, color: Colors.green,),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(downloaded[index]),
                                ],
                              )
                          ),
                        );
                      }),
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
