import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/components/my_block.dart';
import 'package:tetris/components/my_grid.dart';
import 'package:tetris/components/my_shape.dart';

import '../services/shape_def.dart';

class NextShapeFrame {
  static const int rowCount = 6;
  static const int colCount = 7;
  static const double width = colCount * MyBlock.blockWidth;
  static const double height = rowCount * MyBlock.blockHeight;

  World world;
  Vector2 position;
  late ShapeIndex _shapeIndex;
  late MyShape shape;

  late Vector2 _bottomLeftPos;

  NextShapeFrame({
    required this.world,
    required this.position,
  }) {
    _bottomLeftPos =
        position + Vector2(MyBlock.blockWidth, MyBlock.blockHeight * 4);
  }

  Future<void> init() async {
    await _initFrame();
    await _initRandomShape();
  }

  Future<void> _initFrame() async {
    MyGrid grid =
        MyGrid(rowCount: rowCount, colCount: colCount, position: position);
    await world.add(grid);
  }

  ShapeIndex getShapeIndex() {
    return _shapeIndex;
  }

  Future<void> newRandomShape() async {
    _shapeIndex = ShapeDef().getRandomShapeIndex();
    await shape.changeShapeToIndex(_shapeIndex);
  }

  Future<void> _initRandomShape() async {
    _shapeIndex = ShapeDef().getRandomShapeIndex();
    shape = await MyShape.create(
        world: world, shapeIndex: _shapeIndex, bottomLeftPos: _bottomLeftPos);
  }
}
