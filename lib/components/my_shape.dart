import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/components/my_block.dart';
import 'package:tetris/services/shape_def.dart';

class MyShape {
  World world;
  ShapeIndex shapeIndex;
  Vector2 bottomLeftPos;
  late List<MyBlock> blocks;
  ShapeType shapeType = ShapeType.normal;

  MyShape._({
    required this.world,
    required this.shapeIndex,
    required this.bottomLeftPos,
  });

  static Future<MyShape> create({
    required World world,
    required ShapeIndex shapeIndex,
    required Vector2 bottomLeftPos,
  }) async {
    MyShape myShape = MyShape._(
      world: world,
      shapeIndex: shapeIndex,
      bottomLeftPos: bottomLeftPos,
    );
    await myShape._initShape();
    return myShape;
  }

  bool get isSpecialOneBlock => shapeType == ShapeType.specialOneBlock;

  Future<void> _initShape() async {
    shapeType = shapeIndex.getShapeType();
    blocks = [];
    List<Vector2> shapeVector = ShapeDef().getShapeVector(shapeIndex);
    for (Vector2 pos in shapeVector) {
      MyBlock block = MyBlock(isBlinking: _isBlinking(pos));
      block.position = pos + bottomLeftPos;
      blocks.add(block);
    }
    await world.addAll(blocks);
  }

  bool isGunShape() {
    return isBlockGunShape() || isBulletGunShape();
  }

  bool isBlockGunShape() {
    return shapeType == ShapeType.blockGun;
  }

  bool isBulletGunShape() {
    return shapeType == ShapeType.bulletGun;
  }

  bool _isBlinking(Vector2 pos) {
    if (shapeIndex.isSpecialOneBlock()) return true;
    if (shapeType == ShapeType.blockGun) return pos != Vector2(0, 0);
    if (shapeType == ShapeType.bulletGun) return pos == Vector2(0, 0);
    return false;
  }

  void removeBlinkingEffect() {
    if (shapeIndex.isSpecialOneBlock()) {
      List<MyBlock> blocksToRemove = blocks;
      for (var block in blocksToRemove) {
        block.removeBlinkingEffect();
      }
    }
  }

  ShapeIndex getShapeIndex() {
    return shapeIndex;
  }

  Vector2 getBottomLeftPos() {
    return bottomLeftPos;
  }

  void _removeShape() {
    removeBlinkingEffect();
    List<MyBlock> blocksToRemove = blocks;
    world.removeAll(blocksToRemove);
  }

  Future<void> changeShapeToIndex(ShapeIndex shapeIndex) async {
    _removeShape();
    //it seems sometimes the _initShape run before _removeShape; try to fix by adding delay
    await Future.delayed(const Duration(milliseconds: 10));
    this.shapeIndex = shapeIndex;
    await _initShape();
  }

  void move(Vector2 moveVector) {
    for (int i = 0; i < blocks.length; i++) {
      blocks[i].position += moveVector;
    }
    bottomLeftPos += moveVector;
  }

  List<Vector2> getBlockPositions() {
    return blocks.map((e) => e.position).toList();
  }

  List<MyBlock> getBlocks() {
    return blocks;
  }

  static List<Vector2> getShapePositionForIndex(
      ShapeIndex shapeIndex, Vector2 shapeBottomLeft) {
    List<Vector2> shapeVector = ShapeDef().getShapeVector(shapeIndex);
    List<Vector2> shapePos = [];
    for (int i = 0; i < shapeVector.length; i++) {
      shapePos.add(shapeVector[i] + shapeBottomLeft);
    }
    return shapePos;
  }

  List<Vector2> getNewBlockPositionsIfMoveBy(Vector2 moveVector) {
    return blocks.map((e) => e.position + moveVector).toList();
  }

  void updateAfterRotate(ShapeIndex nextIndex, List<Vector2> newShapePos) {
    for (int i = 0; i < blocks.length; i++) {
      blocks[i].position = newShapePos[i];
    }
    shapeIndex = nextIndex;
  }

  void updateAfterRotateAndMove(
      ShapeIndex nextIndex, List<Vector2> newShapePos, Vector2 moveVector) {
    for (int i = 0; i < blocks.length; i++) {
      blocks[i].position = newShapePos[i] + moveVector;
    }
    bottomLeftPos += moveVector;
    shapeIndex = nextIndex;
  }

  MyBlock getBottomBlock() {
    double maxY = blocks[0].position.y;
    int maxIndex = 0;
    for (int i = 1; i < blocks.length; i++) {
      if (blocks[i].position.y > maxY) {
        maxY = blocks[i].position.y;
        maxIndex = i;
      }
    }
    return blocks[maxIndex];
  }
}
