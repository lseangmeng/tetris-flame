import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

class MyButton extends PositionComponent with TapCallbacks {
  static const Color _bgColor = Color(0xffbec1ce);
  static const Color _textColor = Color(0xff484a4f);
  static const double _fontSize = 32;

  static const TextStyle textStyle = TextStyle(color: _textColor, fontSize: _fontSize);
  static final TextPaint textPaint = TextPaint(style: textStyle);

  final _paint = Paint()..color = _bgColor;

  late Rect _rect;
  VoidCallback? onTap;
  VoidCallback? onButtonLongTapDown;
  VoidCallback? onButtonActive;
  VoidCallback? onButtonInactive;
  String text;
  Vector2 textPos;

  MyButton({
    super.position,
    super.size,
    required this.text,
    required this.textPos,
    this.onTap,
    this.onButtonLongTapDown,
    this.onButtonActive,
    this.onButtonInactive,
  }) {
    _rect = Rect.fromLTWH(0, 0, size.x, size.y);
  }

  @override
  bool containsLocalPoint(Vector2 point) => _rect.contains(point.toOffset());

  @override
  void onTapUp(TapUpEvent event) {
    if (onTap != null) {
      onTap!();
    }
    if (onButtonInactive != null) onButtonInactive!();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (onButtonActive != null) onButtonActive!();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (onButtonInactive != null) onButtonInactive!();
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (onButtonLongTapDown != null) {
      onButtonLongTapDown!();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
    textPaint.render(canvas, text, textPos);
  }
}
