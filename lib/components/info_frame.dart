import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/components/my_block.dart';

import '../services/level.dart';
import '../services/score.dart';
import 'my_grid.dart';

class InfoFrame {
  static const String highScoreKey = "highScore";
  static const int rowCount = 7;
  static const int colCount = 7;
  static const double width = colCount * MyBlock.blockWidth;
  static const double height = rowCount * MyBlock.blockHeight;
  static const Color _textColor = Color(0xff484a4f);
  static const double _fontSize = 32;

  final World world;
  final Vector2 position;
  final score = Score();
  final level = Level();
  int highScore = 0;
  final TextComponent highScoreText = TextComponent();
  final TextComponent scoreText = TextComponent();
  final TextComponent levelText = TextComponent();
  final TextComponent goalText = TextComponent();
  final TextStyle _style = const TextStyle(color: _textColor, fontSize: _fontSize);
  late TextPaint regularPaint;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  InfoFrame({required this.world, required this.position}) {
    regularPaint = TextPaint(style: _style);
  }

  Future<void> init() async {
    await _initFrame();
    await _initScoreText();
  }

  Future<void> _initFrame() async {
    MyGrid grid = MyGrid(rowCount: rowCount, colCount: colCount, position: position);
    await world.add(grid);
  }

  Future<void> _initScoreText() async {
    final SharedPreferences prefs = await _prefs;
    highScore = prefs.getInt(highScoreKey) ?? 0;

    const double textX = 10;
    const double textY = 25;
    const double textVerticalGap = 60;

    highScoreText
      ..text = _getHighScoreDisplay()
      ..textRenderer = regularPaint
      ..position = position + Vector2(textX, textY);
    scoreText
      ..text = _getScoreDisplay()
      ..textRenderer = regularPaint
      ..position = position + Vector2(textX, textY + textVerticalGap);
    goalText
      ..text = _getGoalDisplay()
      ..textRenderer = regularPaint
      ..position = position + Vector2(textX, textY + textVerticalGap * 2);
    levelText
      ..text = _getLevelDisplay()
      ..textRenderer = regularPaint
      ..position = position + Vector2(textX, textY + textVerticalGap * 3);
    await world.add(highScoreText);
    await world.add(scoreText);
    await world.add(levelText);
    await world.add(goalText);
  }

  void restart() {
    score.reset();
    level.reset();
    _updateDisplayText();
  }

  Future<void> updateScoreAndLevel(int numRowsCleared) async {
    score.increaseWithRowsCleared(numRowsCleared);
    level.increaseWithRowsCleared(numRowsCleared);

    if (score.value > highScore) {
      highScore = score.value;
      final pref = await _prefs;
      pref.setInt(highScoreKey, highScore);
    }

    _updateDisplayText();
  }

  void _updateDisplayText() {
    highScoreText.text = _getHighScoreDisplay();
    scoreText.text = _getScoreDisplay();
    levelText.text = _getLevelDisplay();
    goalText.text = _getGoalDisplay();
  }

  String _getHighScoreDisplay() {
    return "High Score: $highScore";
  }

  String _getScoreDisplay() {
    return "Score: ${score.value}";
  }

  String _getLevelDisplay() {
    return "Level: ${level.value}";
  }

  String _getGoalDisplay() {
    return "Goal: ${level.rowsClearedSinceLastLevel} / ${level.numRowsClearedToNextLevel}";
  }

}
