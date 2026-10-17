import 'package:audioplayers/audioplayers.dart';

class PlaySound {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static void playClickSound(String media) async {
    await _audioPlayer.play(AssetSource(media));
  }
}
