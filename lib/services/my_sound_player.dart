import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MySoundPlayer {
  /// Access a shared instance of the [AudioCache] class.
  static AudioCache audioCache = AudioCache(prefix: 'assets/audio/');
  static Map<String, MySoundPlayer> playerMap = {};
  static bool _soundOn = true;
  final player = AudioPlayer()
    ..audioCache = audioCache
    ..setReleaseMode(ReleaseMode.release);

  final String soundName;
  bool _isPlaying = false;

  MySoundPlayer(this.soundName) {
    player.onPlayerComplete.listen((event) {
      _isPlaying = false;
    });
  }

  static void turnSoundOff() {
    _soundOn = false;
  }
  static void turnSoundOn() {
    _soundOn = true;
  }
  static void toggleSoundOnOff() {
    _soundOn = !_soundOn;
  }
  static bool isSoundOn() {
    return _soundOn;
  }

  static Future<void> init() async {
    await audioCache.loadAll(_SoundConst.preloadSounds);
    for (String soundName in _SoundConst.preloadSounds) {
      playerMap[soundName] = MySoundPlayer(soundName);
    }
    debugPrint("playerMap[$playerMap]");
  }

  static Future<void> playRotateSound() async {
    await _play(_SoundConst.rotate);
  }
  static Future<void> playLeftRightSound() async {
    await _play(_SoundConst.leftRight);
  }
  static Future<void> playDownSound() async {
    await _play(_SoundConst.down);
  }
  static Future<void> playBlockHitBottomSound() async {
    await _play(_SoundConst.blockHitBottom);
  }
  static Future<void> playClearRowSound() async {
    await _play(_SoundConst.clearRow);
  }

  static Future<void> _play(String soundName) async {
    if (! _soundOn) return;
    if (! playerMap.containsKey(soundName)) {
      debugPrint("soundName[$soundName] not found! Sound not played!");
      return;
    }
    try {
      await playerMap[soundName]!.play();
    } catch (e) {
      debugPrint(e.toString());
      debugPrintStack();
    }
  }

  Future<void> play() async {
    if (_isPlaying) {
      await player.seek(Duration.zero);
      return;
    }

    _isPlaying = true;
    await player.play(
      AssetSource(soundName),
      volume: 1.0,
      mode: PlayerMode.mediaPlayer,
    );
  }
}

class _SoundConst {
  static const String blockHitBottom = "block_hit_bottom.mp3";
  static const String clearRow = "clear_row.mp3";
  static const String down = "down.mp3";
  static const String leftRight = "left_right.mp3";
  static const String rotate = "rotate.mp3";

  static const List<String> preloadSounds = [
    blockHitBottom,
    clearRow,
    down,
    leftRight,
    rotate,
  ];
}