import 'dart:ui';

import 'package:flame/components.dart';

import 'my_block.dart';

class MyGrid extends PositionComponent {
  static const double _blockWidth = MyBlock.blockWidth;
  static const double _blockHeight = MyBlock.blockHeight;

  static final _gridFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1
    ..color = const Color(0xffbec1ce);

  static final _gridLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0x20484a4f);

  final int rowCount;
  final int colCount;

  late double _width;
  late double _height;

  MyGrid({required this.rowCount, required this.colCount, super.position}) {
    _width = _blockWidth * colCount;
    _height = _blockHeight * rowCount;
    size = Vector2(_width, _height);
  }

  @override
  void render(Canvas canvas) {
    final blockRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, _width, _height),
      const Radius.circular(5),
    );
    canvas.drawRRect(blockRect, _gridFillPaint);
    for (int c = 1; c < colCount ; c++) {
      canvas.drawLine(
        Offset(c * _blockWidth, 0),
        Offset(c * _blockWidth, height),
        _gridLinePaint,
      );
    }
    for (int r = 1; r < rowCount; r++) {
      canvas.drawLine(
        Offset(0, r * _blockHeight),
        Offset(width, r * _blockHeight),
        _gridLinePaint,
      );
    }
  }
}
