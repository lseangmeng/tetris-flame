import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/services/shape_control_service.dart';

class ShapeControlKeyboard {
  static const double longPressedMillis = 500;

  DateTime? lastLeftPressed;
  DateTime? lastRightPressed;
  DateTime? lastDownPressed;

  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);
    final isArrowLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isArrowRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isArrowDown = keysPressed.contains(LogicalKeyboardKey.arrowDown);
    final isArrowUp = keysPressed.contains(LogicalKeyboardKey.arrowUp);

    // debugPrint("isKeyDown[$isKeyDown] down[$isArrowDown]");

    if (isKeyDown) {
      _handleLeftArrow(isArrowLeft);
      _handleRightArrow(isArrowRight);
      _handleDownArrow(isArrowDown);
      _handleRotate(isSpace || isArrowUp);

      if (! isArrowLeft && ! isArrowRight && ! isArrowDown && ! isSpace && ! isArrowUp) {
        ShapeControlService().firePressedCompleted();
      }

      return KeyEventResult.handled;
    } else {
      lastLeftPressed = null;
      lastRightPressed = null;
      lastDownPressed = null;
      ShapeControlService().firePressedCompleted();
    }
    return KeyEventResult.ignored;

  }

  void _handleRightArrow(bool isArrowRight) {
    if (isArrowRight) {
      ShapeControlService().fireRightLongPressed();
    }
  }

  void _handleLeftArrow(bool isArrowLeft) {
    if (isArrowLeft) {
      ShapeControlService().fireLeftLongPressed();
    }
  }

  void _handleDownArrow(bool isArrowDown) {
    if (isArrowDown) {
      ShapeControlService().fireDownLongPressed();
    }
  }

  void _handleRotate(bool isRotate) {
    if (isRotate) {
       ShapeControlService().fireRotatePressed();
    }
  }

}