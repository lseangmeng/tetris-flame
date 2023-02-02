import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/constants/const.dart';
import 'package:tetris/services/my_sound_player.dart';

import 'my_button.dart';

class SoundButton {
  final Vector2 position;
  final World world;
  MyButton? button;

  SoundButton({
    required this.position,
    required this.world,
  });

  Future<void> init() async {
    button = MyButton(
      onTap: onTap,
      text: _soundOnText(),
      textPos: Vector2(20, 15),
      size: Vector2(180, buttonHeight),
      position: position,
    );
    await world.add(button!);
  }

  void onTap() {
    if (button == null) return;
    MySoundPlayer.toggleSoundOnOff();
    if (MySoundPlayer.isSoundOn()) {
      button!.text = _soundOnText();
    } else {
      button!.text = _soundOffText();
    }
  }

  String _soundOffText() {
    return "Sound Off";
  }
  String _soundOnText() {
    return "Sound On";
  }
}
