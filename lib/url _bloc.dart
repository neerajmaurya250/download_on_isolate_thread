import 'dart:async';

class DownloadUrl {
  StreamController<List<String>> urlStreamController = StreamController<List<String>>.broadcast();

  void dispose() {
    urlStreamController.close();
  }
}
