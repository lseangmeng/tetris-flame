import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/my_block.dart';

String _blockChar = 'O';
const double blockWidth = MyBlock.blockWidth;
const double blockHeight = MyBlock.blockHeight;

class ShapeDef {
  static final ShapeDef _instance = ShapeDef._();
  factory ShapeDef() => _instance;
  static final List<Vector2> _notFoundShapeVector = _getNotFoundShapeVector();

  GameMode _gameMode = GameMode.hard;

  //for debugging
  bool _onlySpecialOneBlock = false;
  bool _onlyBlockGunShape = false;
  bool _onlyBulletGunShape = false;

  ShapeDef._() {
    debugPrint("shapeGroups.length = [${_shapeGroups.length}]");
  }

  void setToEasyMode() { _gameMode = GameMode.easy; }
  void setToMediumMode() { _gameMode = GameMode.medium; }
  void setToHardMode() { _gameMode = GameMode.hard; }

  void toggleOnlySpecialOneBlock() {
    _onlySpecialOneBlock = !_onlySpecialOneBlock;
  }

  void toggleOnlyBlockGunShape() {
    _onlyBlockGunShape = !_onlyBlockGunShape;
  }

  void toggleOnlyBulletGunShape() {
    _onlyBulletGunShape = !_onlyBulletGunShape;
  }

  ShapeIndex getRandomShapeIndex() {
    if (_onlySpecialOneBlock) {
      return _getSpecialOneBlockShapeIndex();
    } else if (_onlyBlockGunShape) {
      return _getBlockGunShapeIndex();
    } else if (_onlyBulletGunShape) {
      return _getBulletGunShapeIndex();
    }
    // return ShapeIndex(groupIndex: 0, indexInGroup: 0);
    Random random = Random();
    int groupIndex = random.nextInt(_getShapeGroupCount());
    final ShapeGroup shapeGroup = _getShapeGroups()[groupIndex];
    int indexInGroup = random.nextInt(shapeGroup.vectors.length);
    return ShapeIndex(
      shapeGroup: shapeGroup,
      indexInGroup: indexInGroup,
    );
  }

  List<Vector2> getShapeVector(ShapeIndex shapeIndex) {
    if (shapeIndex.isBlockGun()) return _getShapeVectorBlockGun();
    if (shapeIndex.isBulletGun()) return _getShapeVectorBulletGun();

    ShapeGroup shapeGroup = shapeIndex.shapeGroup;
    if (shapeIndex.indexInGroup >= shapeGroup.vectors.length) {
      return _notFoundShapeVector;
    }
    return shapeGroup.vectors[shapeIndex.indexInGroup];
  }

  ShapeIndex getNextShapeIndexAfterRotate(ShapeIndex currentIndex) {
    ShapeGroup shapeGroup = currentIndex.shapeGroup;
    int indexInGroup = currentIndex.indexInGroup + 1;
    if (indexInGroup >= shapeGroup.vectors.length) indexInGroup = 0;
    return ShapeIndex(
      shapeGroup: shapeGroup,
      indexInGroup: indexInGroup,
    );
  }


  List<ShapeGroup> _getShapeGroups() {
    if (_gameMode == GameMode.easy) {
      return _easyShapeGroups;
    } else if (_gameMode == GameMode.medium) {
      return _mediumShapeGroups;
    }
    return _hardShapeGroups;
  }

  int _getShapeGroupCount() {
    return _getShapeGroups().length;
  }

  List<Vector2> _getShapeVectorBulletGun() {
    return _shapeGroups
        .where((shapeGroup) => shapeGroup.isBulletGun())
        .first
        .vectors[0];
  }

  List<Vector2> _getShapeVectorBlockGun() {
    return _shapeGroups
        .where((shapeGroup) => shapeGroup.isBlockGun())
        .first
        .vectors[0];
  }

  ShapeIndex _getSpecialOneBlockShapeIndex() {
    for (int groupIndex = 0; groupIndex < _shapeGroups.length; groupIndex++) {
      final shapeGroup = _shapeGroups[groupIndex];
      if (shapeGroup.shapeType == ShapeType.specialOneBlock) {
        return ShapeIndex(
          shapeGroup: shapeGroup,
          indexInGroup: 0,
        );
      }
    }
    return ShapeIndex(shapeGroup: _shapeGroups[0], indexInGroup: 0);
  }

  ShapeIndex _getBlockGunShapeIndex() {
    for (int groupIndex = 0; groupIndex < _shapeGroups.length; groupIndex++) {
      final shapeGroup = _shapeGroups[groupIndex];
      if (shapeGroup.shapeType == ShapeType.blockGun) {
        return ShapeIndex(
          shapeGroup: shapeGroup,
          indexInGroup: 0,
        );
      }
    }
    return ShapeIndex(shapeGroup: _shapeGroups[0], indexInGroup: 0);
  }

  ShapeIndex _getBulletGunShapeIndex() {
    for (int groupIndex = 0; groupIndex < _shapeGroups.length; groupIndex++) {
      final shapeGroup = _shapeGroups[groupIndex];
      if (shapeGroup.shapeType == ShapeType.bulletGun) {
        return ShapeIndex(
          shapeGroup: shapeGroup,
          indexInGroup: 0,
        );
      }
    }
    return ShapeIndex(shapeGroup: _shapeGroups[0], indexInGroup: 0);
  }

}

/*
not found shape
3 4
 2
0 1
*/
List<Vector2> _getNotFoundShapeVector() {
  return _shapeGroupDefToShapeGroup("""
  | O O |
  |  O  |
  | O O |
  """)[0];
}

final List<ShapeGroup> _shapeGroups = _buildShapeGroups();
final List<ShapeGroup> _easyShapeGroups = _shapeGroups.where((e) => !e.isComplex()).toList();
final List<ShapeGroup> _mediumShapeGroups = _shapeGroups.where((e) => e.isNormal()).toList();
final List<ShapeGroup> _hardShapeGroups = _shapeGroups.where((e) => !e.isHelper()).toList();
List<ShapeGroup> _buildShapeGroups() {
  List<ShapeGroup> shapeGroups = [];
  int i = 0;
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | OO |     |  O |     |
  | O  | OOO |  O | O   |
  | O  |   O | OO | OOO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | OO |     | O  |     |
  |  O |   O | O  | OOO |
  |  O | OOO | OO | O   |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O  |     |  O |     |
  | OO | OOO | OO |  O  |
  | O  |  O  |  O | OOO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  | O  |     |  O |     |
  |  O | O O | O  |  O  |
  | O  |  O  |  O | O O |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  |     | OO |     | OO |
  | O O | O  | OOO |  O |
  | OOO | OO | O O | OO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O  | OO | OO |  O |
  | OO | O  |  O | OO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  |  O  | O   | OOO |   O |
  |  O  | OOO |  O  | OOO |
  | OOO | O   |  O  |   O |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  |   O | O   | OOO | OOO |
  |   O | O   | O   |   O |
  | OOO | OOO | O   |   O |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  |  O |     |
  | OO | OO  |
  | O  |  OO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O  |     |
  | OO |  OO |
  |  O | OO  |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O |      |
  | O |      |
  | O |      |
  | O | OOOO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O |     |
  | O |     |
  | O | OOO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | O |    |
  | O | OO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  | O  |  O |
  |  O | O  |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.normal(_shapeGroupDefToShapeGroup("""
  | OO |
  | OO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  | OOO |
  | O O |
  | OOO |
  """), groupIndex: i++));
  shapeGroups.add(ShapeGroup(_shapeGroupDefToShapeGroup("""
  | O |
  """), shapeType: ShapeType.specialOneBlock, groupIndex: i++));
  shapeGroups.add(ShapeGroup(_shapeGroupDefToShapeGroup("""
  | O |
  | O |
  | O |
  | O |
  """), shapeType: ShapeType.blockGun, groupIndex: i++));
  shapeGroups.add(ShapeGroup(_shapeGroupDefToShapeGroup("""
  | O |
  | O |
  | O |
  | O |
  """), shapeType: ShapeType.bulletGun, groupIndex: i++));
  shapeGroups.add(ShapeGroup.complex(_shapeGroupDefToShapeGroup("""
  |  O  |
  | OOO |
  |  O  |
  """), groupIndex: i++));
  return shapeGroups;
}

/*
List<String> shapeDef = [
  " OO ",
  " O  ",
  " O  ",
];
List<Vector2> shapeVector = [
  Vector2(0, 0), Vector2(0, -h), Vector2(0, -h2), Vector2(w, -h2),
]; //relative to bottom left
*/
List<Vector2> _shapeDefToShapeVector(List<String> shapeDef) {
  if (shapeDef.isEmpty) return [];
  double w = blockWidth;
  double h = blockHeight;
  List<Vector2> shapeVector = [];
  int rowCount = shapeDef.length;
  int minIndex = _getMinLeftIndex(shapeDef);
  int colCount = shapeDef[0].length - minIndex;
  for (int r = 0; r < rowCount; r++) {
    String rowDef = shapeDef[rowCount - 1 - r];
    for (int c = 0; c < colCount; c++) {
      if (rowDef[c + minIndex] == _blockChar) {
        shapeVector.add(Vector2(w * c, -r * h));
      }
    }
  }
  return shapeVector;
}

int _getMinLeftIndex(List<String> shapeDef) {
  if (shapeDef.isEmpty) return -1;
  int minIndex = shapeDef[0].indexOf(_blockChar);
  for (int i = 1; i < shapeDef.length; i++) {
    int index = shapeDef[i].indexOf(_blockChar);
    if (index < minIndex) minIndex = index;
  }
  return minIndex;
}

List<List<Vector2>> _shapeGroupDefToShapeGroup(String shapeGroupDef) {
  return _shapeGroupDefStrToShapeGroupDef(shapeGroupDef)
      .map(_shapeDefToShapeVector)
      .toList();
}

List<List<String>> _shapeGroupDefStrToShapeGroupDef(String shapeGroupDefStr) {
  List<List<String>> shapeLinesList = [];
  List<String> shapeLines = [];
  List<String> lines = const LineSplitter().convert(shapeGroupDefStr);
  int startFrom = 0;
  int i1 = 0, i2 = 0;
  bool finished = false;
  while (!finished) {
    shapeLines = [];
    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      i1 = line.indexOf('|', startFrom);
      if (i1 < 0) {
        finished = true;
        break;
      }
      i2 = line.indexOf('|', i1 + 1);
      if (i2 < 0) {
        finished = true;
        break;
      }
      String sub = line.substring(i1 + 1, i2);
      if (sub.trim().isNotEmpty) {
        shapeLines.add(sub);
      }
    }
    startFrom = i2;
    if (shapeLines.isNotEmpty) {
      shapeLinesList.add(shapeLines);
    }
  }
  return shapeLinesList;
}

class ShapeIndex {
  ShapeGroup shapeGroup;
  int indexInGroup;

  ShapeIndex({
    required this.shapeGroup,
    required this.indexInGroup,
  });

  @override
  String toString() {
    return 'ShapeIndex{groupIndex: ${shapeGroup.groupIndex}, indexInGroup: $indexInGroup}';
  }

  bool isBlockGun() {
    return shapeGroup.shapeType == ShapeType.blockGun;
  }

  bool isBulletGun() {
    return shapeGroup.shapeType == ShapeType.bulletGun;
  }

  ShapeType getShapeType() {
    return shapeGroup.shapeType;
  }

  bool isSpecialOneBlock() { return shapeGroup.shapeType == ShapeType.specialOneBlock; }
}

enum ShapeType {
  normal,
  complex,
  specialOneBlock,
  blockGun,
  bulletGun;
}

extension ShapeTypeExtension on ShapeType {
  bool isHelper() {
    return this == ShapeType.specialOneBlock ||
        this == ShapeType.blockGun ||
        this == ShapeType.bulletGun;
  }
  bool isNormal() {
    return this == ShapeType.normal;
  }
  bool isComplex() {
    return this == ShapeType.complex;
  }
}

class ShapeGroup {
  ShapeType shapeType = ShapeType.normal;
  List<List<Vector2>> vectors;
  final int groupIndex;

  ShapeGroup(this.vectors, {
    required this.groupIndex,
    this.shapeType = ShapeType.normal,
  });

  ShapeGroup.complex(this.vectors, {required this.groupIndex}) : shapeType = ShapeType.complex;

  ShapeGroup.normal(this.vectors, {required this.groupIndex}) : shapeType = ShapeType.normal;

  bool isBulletGun() {
    return shapeType == ShapeType.bulletGun;
  }

  bool isBlockGun() {
    return shapeType == ShapeType.blockGun;
  }

  bool isBlinking() {
    return shapeType == ShapeType.specialOneBlock;
  }

  bool isComplex() { return shapeType.isComplex(); }
  bool isNormal() { return shapeType.isNormal(); }
  bool isHelper() { return shapeType.isHelper(); }
}

enum GameMode {
  easy, medium, hard
}
