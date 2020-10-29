import 'dart:async';

class DownloadUrl {
  StreamController<List<String>> urlStreamController = StreamController<List<String>>.broadcast();

  void dispose() {
    urlStreamController.close();
  }
}

class DownloadedList {
  StreamController<String> downloadedListStreamController = StreamController<String>.broadcast();

  void dispose(){
    downloadedListStreamController.close();
  }
}
