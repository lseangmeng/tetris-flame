import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class MyBlock extends PositionComponent with HasPaint {
  static const double blockWidth = 40;
  static const double blockHeight = 40;
  static const double _blockGap = 1;
  static final Vector2 _blockSize = Vector2(blockWidth, blockHeight);
  static const Color _blockColor = Color(0xff484a4f);
  static const Color _blockColorTransparent = Color(0x00484a4f);

  final BlockType blockType;
  bool isBlinking = false;
  Effect? _blinkingEffect;
  final _blockRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(
      _blockGap,
      _blockGap,
      blockWidth - _blockGap * 2,
      blockHeight - _blockGap * 2,
    ),
    const Radius.circular(5),
  );

  MyBlock({this.isBlinking = false, this.blockType = BlockType.normal})
      : super(size: _blockSize) {
    paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = _blockColor;
    _addBlinkingEffect();
  }

  void _addBlinkingEffect() {
    if (isBlinking) {
      _blinkingEffect = OpacityEffect.to(
        0.1,
        InfiniteEffectController(EffectController(duration: 1)),
      );
      add(_blinkingEffect!);
    }
  }

  void removeBlinkingEffect() {
    if (isBlinking) {
      remove(_blinkingEffect!);
      paint.color = _blockColor;
    }
  }


  void becomeTransparent() {
    paint.color = _blockColorTransparent;
  }

  void becomeOpaque() {
    paint.color = _blockColor;
  }

  void move(Vector2 moveVector) {
    position += moveVector;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_blockRect, paint);
  }

  bool isBlockGun() {
    return blockType == BlockType.blockGun;
  }

  bool isBulletGun() {
    return blockType == BlockType.bulletGun;
  }

  @override
  String toString() {
    return 'MyBlock{blockType: $blockType, position: $position}';
  }
}

enum BlockType {
  normal,
  blockGun,
  bulletGun;
}
