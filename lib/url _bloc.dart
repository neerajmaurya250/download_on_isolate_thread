import 'dart:async';

class DownloadUrl{
  final urlStreamController = StreamController<String>.broadcast();

  void dispose(){
    urlStreamController.close();
  }
}