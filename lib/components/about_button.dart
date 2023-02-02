import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/constants/const.dart';

import 'my_button.dart';

class AboutButton {
  final Vector2 position;
  final World world;
  final VoidCallback onTap;

  AboutButton({
    required this.position,
    required this.world,
    required this.onTap,
  });

  Future<void> init() async {
    MyButton aboutButton = MyButton(
      onTap: onTap,
      text: "About",
      textPos: Vector2(30, 15),
      size: Vector2(150, buttonHeight),
      position: position,
    );
    await world.add(aboutButton);
  }
}
