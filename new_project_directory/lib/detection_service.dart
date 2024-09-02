// lib/detection_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DetectionService {
  final AudioPlayer audioPlayer = AudioPlayer();

  void startDetection(Function onBarkDetected) {
    // Código para iniciar la detección...
    // Llama a onBarkDetected() cuando se detecte un ladrido
  }

  void stopDetection() {
    // Detener la detección
  }

  void playSelectedSound(String fileName) async {
    String url = await FirebaseStorage.instance.ref('sounds/$fileName').getDownloadURL();
    await audioPlayer.play(UrlSource(url));
  }
}
