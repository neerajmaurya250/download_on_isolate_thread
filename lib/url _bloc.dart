import 'dart:async';

class DownloadUrl {
  StreamController<List<String>> urlStreamController = StreamController<List<String>>.broadcast();

  void dispose() {
    urlStreamController.close();
  }
}

class DownloadProgress {
  StreamController<double> downloadStreamController = StreamController<double>.broadcast();

  void dispose(){
    downloadStreamController.close();
  }
}
