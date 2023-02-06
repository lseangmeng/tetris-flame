import 'dart:collection';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/foundation.dart';
import 'package:tetris/components/my_block.dart';
import 'package:tetris/components/my_grid.dart';
import 'package:tetris/services/my_sound_player.dart';
import 'package:tetris/services/shape_def.dart';

import '../services/shape_control_service.dart';
import 'my_shape.dart';

class PlayingFrame {
  final blockToRemovePaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1
    ..color = const Color(0x88484a4f);

  static const int rowCount = 20;
  static const int colCount = 10;
  static const double blockHeight = MyBlock.blockWidth;
  static const double blockWidth = MyBlock.blockHeight;
  static const double width = colCount * blockWidth;
  static const double height = rowCount * blockHeight;
  DateTime _lastDown = DateTime.now();
  DateTime _lastLeft = DateTime.now();
  DateTime _lastRight = DateTime.now();
  DateTime _lastRotate = DateTime.now();
  static const int millisPerLeftRightEventHandling = 100;
  static const int millisPerRotateKeyboardHandling = 150;
  static const int millisPerDownKeyboardHandling = 20;
  World world;
  Vector2 position;
  List<List<MyBlock?>> blockAt = [];
  late MyShape fallingShape;
  bool fallingShapeIsActive = false;
  double fallingSpeedPixelsPerSecond;
  late double _gunBlockFallingSpeedPixelsPerSecond;
  double _totalPixelsToMoveDown = 0;
  double _totalPixelsToMoveDownForGunBlocks = 0;
  void Function(GameState, int, int) onShapeHitBottom;
  GameState gameState = GameState.notPlaying;
  Future<ShapeIndex> Function() nextRandomShapeIndex;
  int rowToRemove = -1;
  double removingRowsElapsedTimes = 0;

  bool _isLeftKeyActive = false;
  bool _isRightKeyActive = false;
  bool _isDownKeyActive = false;
  final bool _isChangeKeyActive = false;

  Queue<MyBlock> gunBlocks = Queue();

  PlayingFrame({
    required this.world,
    required this.position,
    required this.fallingSpeedPixelsPerSecond,
    required this.nextRandomShapeIndex,
    required this.onShapeHitBottom,
    required Stream<ShapeControlEvent> buttonPressedInfoStream,
  }) {
    _gunBlockFallingSpeedPixelsPerSecond = 25 * fallingSpeedPixelsPerSecond;
    buttonPressedInfoStream.listen(_handleShapeControlEvent);
  }
  Future<void> init() async {
    await _initFrame();
    _initBlockAt();
  }

  Future<void> start() async {
    gameState = GameState.playing;
    await _startFallingShape();
  }

  Future<void> restart() async {
    _clearAll();
    await start();
  }

  Future<void> pause() async {
    gameState = GameState.pause;
  }

  Future<void> resume() async {
    gameState = GameState.playing;
  }

  void _handleShapeControlEvent(ShapeControlEvent event) {
    // debugPrint("buttonPressedInfoStream event[$event]");
    if (event.rotatePressed) _rotateShape();
    if (event.leftPressed) _moveShapeLeft();
    if (event.rightPressed) _moveShapeRight();
    if (event.downPressed) _moveShapeDown();

    _isLeftKeyActive = event.leftLongPressed;
    _isRightKeyActive = event.rightLongPressed;
    _isDownKeyActive = event.downLongPressed;
  }

  void _clearAll() {
    world.removeAll(fallingShape.blocks);
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (blockAt[r][c] != null) {
          world.remove(blockAt[r][c]!);
          blockAt[r][c] = null;
        }
      }
    }
  }

  int _getHighestHeight() {
    for (int r = rowCount - 1; r >= 0; r--) {
      for (int c = 0; c < colCount; c++) {
        if (blockAt[r][c] != null) return r + 1;
      }
    }
    return 0;
  }

  Future<void> _startFallingShape() async {
    fallingShapeIsActive = false;
    ShapeIndex shapeIndex = await nextRandomShapeIndex.call();
    Vector2 bottomLeftPos = position +
        Vector2(blockWidth * (colCount / 2 - 1), -blockHeight);
    // Vector2(MyBlock.getWidth() * (colCount / 2 - 1), 5*MyBlock.getHeight());

    fallingShape = await MyShape.create(
        world: world, shapeIndex: shapeIndex, bottomLeftPos: bottomLeftPos);
    fallingShapeIsActive = true;
  }

  void _initBlockAt() {
    blockAt = [];
    for (int r = 0; r < rowCount; r++) {
      List<MyBlock?> blockAtRow = [];
      for (int c = 0; c < colCount; c++) {
        blockAtRow.add(null);
      }
      blockAt.add(blockAtRow);
    }
  }

  Future<void> _initFrame() async {
    final MyGrid grid =
        MyGrid(rowCount: rowCount, colCount: colCount, position: position);
    await world.add(grid);
  }

  void update(double dt) {
    if (gameState == GameState.playing) {
      _updatePlaying(dt);
    } else if (gameState == GameState.removingRows) {
      updateRemovingRows(dt);
    }
  }

  Future<void> updateRemovingRows(double dt) async {
    removingRowsElapsedTimes += dt;
    if (removingRowsElapsedTimes >= 0.25) {
      removingRowsElapsedTimes -= 0.25;
      await _removeFullRow(rowToRemove);
      _shiftAllBlocksDownForClearedRow(rowToRemove);
      _clearFullRows();
    }
  }

  Future<void> _moveShapeLeft() async {
    if (gameState != GameState.playing) return;
    if (!fallingShapeIsActive) return;
    DateTime now = DateTime.now();
    if (now.difference(_lastLeft).inMilliseconds >= millisPerLeftRightEventHandling) {
      _lastLeft = now;
      await MySoundPlayer.playLeftRightSound();
      await _moveLeftByPixels(blockWidth);
    }
  }

  Future<void> _moveShapeRight() async {
    if (gameState != GameState.playing) return;
    if (!fallingShapeIsActive) return;
    DateTime now = DateTime.now();
    if (now.difference(_lastRight).inMilliseconds >=
        millisPerLeftRightEventHandling) {
      _lastRight = now;
      await MySoundPlayer.playLeftRightSound();
      await _moveRightByPixels(blockWidth);
    }
  }

  Future<void> _moveLeftByPixels(double pixels) async {
    await _moveShapeLeftRight(Vector2(-pixels, 0));
  }

  Future<void> _moveRightByPixels(double pixels) async {
    await _moveShapeLeftRight(Vector2(pixels, 0));
  }

  Future<void> _moveShapeLeftRight(Vector2 moveVector) async {
    List<Vector2> newShapePos =
        fallingShape.getNewBlockPositionsIfMoveBy(moveVector);

    GridIndex gridIndex = posToGridIndex(fallingShape.blocks[0].position);
    int colChange = 1;
    if (moveVector.x < 0) colChange = -1;

    if (_canBlocksPlacedAt(newShapePos,
        isSpecialOneBlock: fallingShape.isSpecialOneBlock)) {
      await _restoreBlockPreviouslyMadeTransparent(gridIndex.r, gridIndex.c);
      fallingShape.move(moveVector);
      _makeBlockTransparent(gridIndex.r, gridIndex.c + colChange);
    }
  }

  Future<void> _moveShapeDown() async {
    if (gameState != GameState.playing) return;
    if (!fallingShapeIsActive) return;
    DateTime now = DateTime.now();
    if (now.difference(_lastDown).inMilliseconds >= millisPerDownKeyboardHandling) {
      _lastDown = now;
      await MySoundPlayer.playDownSound();
      await _moveFallingShapeDownByPixels(blockHeight);
    }
  }

  Future<void> _rotateShape() async {
    if (gameState != GameState.playing) return;
    if (!fallingShapeIsActive) return;
    DateTime now = DateTime.now();
    if (now.difference(_lastRotate).inMilliseconds >=
        millisPerRotateKeyboardHandling) {
      _lastRotate = now;
      await MySoundPlayer.playRotateSound();
      if (fallingShape.isGunShape()) {
        await _fireGunShape();
      } else {
        _rotateNormalShape();
      }
    }
  }

  Future<void> _fireGunShape() async {
    MyBlock bottom = fallingShape.getBottomBlock();
    if (gunBlocks.isNotEmpty &&
        gunBlocks.last.position.y <= bottom.position.y) {
      return;
    }
    bool isBlinking = fallingShape.isBulletGunShape();
    BlockType blockType = fallingShape.isBulletGunShape()
        ? BlockType.bulletGun
        : BlockType.blockGun;
    MyBlock gunBlock = MyBlock(isBlinking: isBlinking, blockType: blockType);
    gunBlock.position = bottom.position;
    debugPrint(
        "_fireGunShape [$blockType] fallingShape[${fallingShape.bottomLeftPos}] gunBlock[${gunBlock.position}]");
    gunBlocks.add(gunBlock);
    debugPrint("gunBlocks[$gunBlocks]");
    await world.add(gunBlock);
  }

  void _rotateNormalShape() {
    ShapeIndex nextIndex =
        ShapeDef().getNextShapeIndexAfterRotate(fallingShape.getShapeIndex());
    List<Vector2> newShapePos = MyShape.getShapePositionForIndex(
        nextIndex, fallingShape.getBottomLeftPos());

    if (_canBlocksPlacedAt(newShapePos)) {
      // debugPrint("currentIndex[${fallingShape.getShapeIndex()}] nextIndex[$nextIndex]");
      fallingShape.updateAfterRotate(nextIndex, newShapePos);
    } else {
      _tryMoveLeftRightToFitShapeAfterRotate(nextIndex, newShapePos);
    }
  }

  void _tryMoveLeftRightToFitShapeAfterRotate(
      ShapeIndex nextIndex, List<Vector2> newShapePos) {
    int horizontalBlockCount = _horizontalBlocksCount(newShapePos);
    for (int i = 1; i <= horizontalBlockCount - 1; i++) {
      for (int multiple in [-1, 1]) {
        Vector2 moveVector = Vector2(multiple * i * blockWidth, 0);
        List<Vector2> moveNewShapePos =
            newShapePos.map((e) => e + moveVector).toList();
        if (_canBlocksPlacedAt(moveNewShapePos)) {
          fallingShape.updateAfterRotateAndMove(
              nextIndex, newShapePos, moveVector);
          return;
        }
      }
    }
  }

  int _horizontalBlocksCount(List<Vector2> shapePos) {
    double minX = shapePos[0].x;
    double maxX = shapePos[0].x;
    for (int i = 1; i < shapePos.length; i++) {
      if (minX > shapePos[i].x) minX = shapePos[i].x;
      if (maxX < shapePos[i].x) maxX = shapePos[i].x;
    }
    return (maxX - minX) ~/ blockWidth + 1;
  }

  Future<void> _removeFullRow(int r) async {
    for (int c = 0; c < colCount; c++) {
      world.remove(blockAt[r][c]!);
      blockAt[r][c] = null;
    }
    MySoundPlayer.playClearRowSound();
  }

  void _shiftAllBlocksDownForClearedRow(int clearedRow) {
    for (int r = clearedRow; r + 1 < rowCount; r++) {
      _shiftRowDownFromTo(r + 1, r);
      if (_isEmptyRow(r + 1)) break;
    }
    _clearTopRow();
  }

  void _clearTopRow() {
    for (int c = 0; c < colCount; c++) {
      blockAt[rowCount - 1][c] = null;
    }
  }

  bool _isEmptyRow(int r) {
    for (int c = 0; c < colCount; c++) {
      if (blockAt[r][c] != null) return false;
    }
    return true;
  }

  void _shiftRowDownFromTo(int from, int to) {
    for (int c = 0; c < colCount; c++) {
      blockAt[to][c] = blockAt[from][c];
      _moveBlockDown(blockAt[from][c]);
    }
  }

  void _moveBlockDown(MyBlock? block) {
    if (block == null) return;
    Vector2 moveVector = Vector2(0, blockHeight);
    block.move(moveVector);
  }

  void _highlightRowToBeRemoved(int r) {
    for (int c = 0; c < colCount; c++) {
      blockAt[r][c]!.paint = blockToRemovePaint;
    }
  }

  void _updatePlaying(double dt) {
    _updateFallingShape(dt);
    _updateGunBlocks(dt);
  }

  void _updateGunBlocks(double dt) {
    _totalPixelsToMoveDownForGunBlocks += _gunBlockFallingSpeedPixelsPerSecond * dt;
    double pixelsToMoveDown = 0;
    if (_totalPixelsToMoveDownForGunBlocks >= blockHeight) {
      pixelsToMoveDown = blockHeight;
    }

    if (pixelsToMoveDown == 0) return;

    _totalPixelsToMoveDownForGunBlocks -= pixelsToMoveDown;
    _moveGunBlocksDownByPixels(pixelsToMoveDown);
  }

  Future<void> _updateFallingShape(double dt) async {
    if (_isLeftKeyActive) await _moveShapeLeft();
    if (_isRightKeyActive) await _moveShapeRight();
    if (_isChangeKeyActive) _rotateShape();
    if (_isDownKeyActive) {
      await _moveShapeDown();
    } else {
      await _autoMoveShapeDown(dt);
    }

  }

  Future<void> _autoMoveShapeDown(double dt) async {
    if (gameState != GameState.playing) return;
    _totalPixelsToMoveDown += fallingSpeedPixelsPerSecond * dt;
    double pixelsToMoveDown = 0;
    if (_totalPixelsToMoveDown >= blockHeight) pixelsToMoveDown = blockHeight;

    if (pixelsToMoveDown == 0) return;

    _totalPixelsToMoveDown -= pixelsToMoveDown;
    await _moveFallingShapeDownByPixels(pixelsToMoveDown);
  }

  Future<void> _moveFallingShapeDownByPixels(double pixelsToMoveDown) async {
    Vector2 moveVector = Vector2(0, pixelsToMoveDown);
    List<Vector2> newShapePos =
        fallingShape.getNewBlockPositionsIfMoveBy(moveVector);

    GridIndex gridIndex = posToGridIndex(fallingShape.blocks[0].position);

    if (_canBlocksPlacedAt(newShapePos,
        isSpecialOneBlock: fallingShape.isSpecialOneBlock)) {
      await _restoreBlockPreviouslyMadeTransparent(gridIndex.r, gridIndex.c);
      fallingShape.move(moveVector);
      _makeBlockTransparent(gridIndex.r - 1, gridIndex.c);
    } else {
      await _placeShapeInFixedPos();
    }
  }

  void _moveGunBlocksDownByPixels(double pixelsToMoveDown) {
    if (gunBlocks.isEmpty) return;
    MyBlock firstGunBlock = gunBlocks.first;
    if (firstGunBlock.isBulletGun()) {
      _moveBulletGunsDownByPixels(pixelsToMoveDown);
    } else {
      _moveBlockGunsDownByPixels(pixelsToMoveDown);
    }
  }

  void _moveBlockGunsDownByPixels(double pixelsToMoveDown) {
    if (gunBlocks.isEmpty) return;
    MyBlock firstGunBlock = gunBlocks.first;
    Vector2 moveVector = Vector2(0, blockHeight);
    Vector2 posAfterMove = firstGunBlock.position + moveVector;
    if (_canBlockPlacedAt(posAfterMove)) {
      for (var block in gunBlocks) {
        block.move(moveVector);
      }
    } else {
      gunBlocks.removeFirst();
      GridIndex gridIndex = posToGridIndex(firstGunBlock.position);
      if (gridIndex.r < rowCount && blockAt[gridIndex.r][gridIndex.c] == null) {
        blockAt[gridIndex.r][gridIndex.c] = firstGunBlock;
        _clearFullRows();
      } else {
        world.remove(firstGunBlock);
      }
      _moveBlockGunsDownByPixels(pixelsToMoveDown);
    }
  }

  void _moveBulletGunsDownByPixels(double pixelsToMoveDown) {
    if (gunBlocks.isEmpty) return;
    MyBlock firstGunBlock = gunBlocks.first;
    Vector2 moveVector = Vector2(0, blockHeight);
    Vector2 posAfterMove = firstGunBlock.position + moveVector;
    if (!_canBlockPlacedAt(posAfterMove)) {
      gunBlocks.removeFirst();
      world.remove(firstGunBlock);
      GridIndex gridIndex = posToGridIndex(posAfterMove);
      _removeBlock(gridIndex.r, gridIndex.c);
    }
    for (var block in gunBlocks) {
      block.position += moveVector;
    }
  }

  void _removeBlock(int r, int c) {
    if (_rowOutOfRange(r)) return;
    if (_colOutOfRange(c)) return;
    if (blockAt[r][c] != null) {
      world.remove(blockAt[r][c]!);
      blockAt[r][c] = null;
    }
  }

  bool _rowOutOfRange(int r) => (r < 0 || r >= rowCount);

  bool _colOutOfRange(int c) => (c < 0 || c >= colCount);

  Future<void> _restoreBlockPreviouslyMadeTransparent(int r, int c) async {
    if (!fallingShape.isSpecialOneBlock) return;
    if (_rowOutOfRange(r)) return;
    if (_colOutOfRange(c)) return;
    blockAt[r][c]?.becomeOpaque();
  }

  void _makeBlockTransparent(int r, int c) {
    if (!fallingShape.isSpecialOneBlock) return;
    if (_rowOutOfRange(r)) return;
    if (_colOutOfRange(c)) return;
    blockAt[r][c]?.becomeTransparent();
  }

  Future<void> _placeShapeInFixedPos() async {
    // debugPrint("fallingShape.shapeType[${fallingShape.shapeType}]");
    if (fallingShape.isGunShape()) {
      List<MyBlock> blocksToRemove = fallingShape.blocks;
      world.removeAll(blocksToRemove);
      await _startFallingShape();
      return;
    }
    MySoundPlayer.playBlockHitBottomSound();
    fallingShape.removeBlinkingEffect();
    List<MyBlock> tempBlocks = fallingShape.getBlocks();
    for (MyBlock block in tempBlocks) {
      Vector2 pos = block.position;
      GridIndex index = posToGridIndex(pos);
      if (index.r >= rowCount) {
        gameState = GameState.gameOver;
        debugPrint(
            "GameOver, fallingBlockPos[${fallingShape.getBlockPositions()}]");
        debugPrint("pos[$pos] gridIndex[$index]");
        onShapeHitBottom.call(GameState.gameOver, 0, 0);
        return;
      }
      blockAt[index.r][index.c] = block;
      // debugPrint("_placeShapeInFixedPos pos[$pos] gridIndex[$index]");
    }
    _clearFullRows();
    await _startFallingShape();
  }

  void _clearFullRows() {
    int fullRowCount = _getTotalFullRowsCount();
    int highestHeight = _getHighestHeight();
    onShapeHitBottom.call(
        GameState.playing, fullRowCount, highestHeight - fullRowCount);
    debugPrint("highestHeight[$highestHeight]");
    int r = 0;
    while (r < rowCount) {
      if (_isRowFull(r)) {
        rowToRemove = r;
        _highlightRowToBeRemoved(rowToRemove);
        gameState = GameState.removingRows;
        break;
      } else {
        gameState = GameState.playing;
        rowToRemove = -1;
        r++;
      }
    }
    debugPrint("gameState[$gameState]");
  }

  int _getTotalFullRowsCount() {
    int fullRowCount = 0;
    for (int r = 0; r < rowCount; r++) {
      int blockCount = _getCountBlocksInRow(r);
      if (blockCount == 0) break;

      bool isFullRow = (blockCount == colCount);
      if (isFullRow) fullRowCount++;
    }
    return fullRowCount;
  }

  int _getCountBlocksInRow(int r) {
    int count = 0;
    for (int c = 0; c < colCount; c++) {
      if (hasBlockAt(r, c)) count++;
    }
    return count;
  }

  bool _isRowFull(int r) {
    for (int c = 0; c < colCount; c++) {
      if (! hasBlockAt(r, c)) return false;
    }
    return true;
  }

  bool _canBlocksPlacedAt(List<Vector2> blockPositions,
      {bool isSpecialOneBlock = false}) {
    for (Vector2 blockPosition in blockPositions) {
      if (!_canBlockPlacedAt(blockPosition,
          isSpecialOneBlock: isSpecialOneBlock)) return false;
    }
    return true;
  }

  bool _canBlockPlacedAt(Vector2 blockPosition,
      {bool isSpecialOneBlock = false}) {
    GridIndex index = posToGridIndex(blockPosition);
    if (_colOutOfRange(index.c)) return false;
    if (index.r < 0) return false;
    if (index.r >= rowCount) {
      return true;
    } //we use space above the top to place initial shape
    if (isSpecialOneBlock) {
      for (int r = index.r; r >= 0; r--) {
        if (!hasBlockAt(r, index.c)) return true;
      }
      return false;
    } else {
      return !hasBlockAt(index.r, index.c);
    }
  }

  bool hasBlockAt(int r, int c) {
    return blockAt[r][c] != null;
  }

  GridIndex posToGridIndex(Vector2 pos) {
    double centerX = pos.x - position.x + blockWidth / 2;
    double centerY = pos.y - position.y + blockHeight / 2;
    int c = (centerX / blockWidth).floor();
    int r = rowCount - 1 - (centerY / blockHeight).floor();
    return GridIndex(r, c);
  }

  static GridIndex posToGridForDebug(Vector2 pos, Vector2 mainFramePos) {
    double centerX = pos.x - mainFramePos.x + blockWidth / 2;
    double centerY = pos.y - mainFramePos.y + blockHeight / 2;
    int c = (centerX / blockWidth).floor();
    int r = rowCount - 1 - (centerY / blockHeight).floor();
    return GridIndex(r, c);
  }
}

class GridIndex {
  int r;
  int c;

  GridIndex(this.r, this.c);

  @override
  String toString() {
    return 'GridIndex{r: $r, c: $c}';
  }
}

enum GameState { notPlaying, playing, pause, removingRows, gameOver }
