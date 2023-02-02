import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/services/shape_control_service.dart';

import '../constants/const.dart';
import 'my_button.dart';

class ShapeControlComponent {
  final Vector2 position;
  final ShapeControlService shapeControlService;

  ShapeControlComponent(this.position, this.shapeControlService);

  Future<void> init(World world) async {
    Vector2 textSize = Vector2(120, buttonHeight);
    double textGap = 10;

    MyButton rotateButton = MyButton(
      onButtonActive: shapeControlService.fireRotatePressed,
      onButtonInactive: shapeControlService.firePressedCompleted,
      position: position + Vector2(textSize.x/2 + textGap/2, 0),
      size: textSize,
      text: "↑",
      textPos: Vector2(50, -10),
    );
    await world.add(rotateButton);

    MyButton leftButton = MyButton(
      onButtonActive: shapeControlService.fireLeftPressed,
      onButtonLongTapDown: shapeControlService.fireLeftLongPressed,
      onButtonInactive: shapeControlService.firePressedCompleted,
      position: position + Vector2(0, textSize.y + textGap),
      size: textSize,
      text: "←",
      textPos: Vector2(40, -5),
    );
    await world.add(leftButton);

    MyButton rightButton = MyButton(
      onButtonActive: shapeControlService.fireRightPressed,
      onButtonLongTapDown: shapeControlService.fireRightLongPressed,
      onButtonInactive: shapeControlService.firePressedCompleted,
      position: position + textSize + Vector2(textGap, textGap),
      size: leftButton.size,
      text: "→",
      textPos: Vector2(40, -5),
    );
    await world.add(rightButton);

    MyButton downButton = MyButton(
      onButtonActive: shapeControlService.fireDownPressed,
      onButtonLongTapDown: shapeControlService.fireDownLongPressed,
      onButtonInactive: shapeControlService.firePressedCompleted,
      position: position + Vector2(textSize.x/2 + textGap/2, textSize.y * 2 + textGap * 2),
      size: leftButton.size,
      text: "↓",
      textPos: Vector2(50, -5),
    );
    await world.add(downButton);

  }
}
