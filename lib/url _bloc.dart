import 'dart:async';

class DownloadUrl {
  StreamController<List<int>> urlStreamController = StreamController<List<int>>.broadcast();

  void dispose() {
    urlStreamController.close();
  }
}
