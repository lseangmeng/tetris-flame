import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:tetris/constants/const.dart';

import 'my_button.dart';

class GameControlComponent {
  final World world;
  final Vector2 position;
  final VoidCallback onStartTap;
  final VoidCallback onRestartTap;
  final VoidCallback onPauseTap;
  final VoidCallback onResumeTap;

  late MyButton startButton;
  late MyButton restartButton;
  late MyButton pauseButton;
  late MyButton resumeButton;
  late MyButton lastShownButton;

  GameControlComponent({
    required this.world,
    required this.position,
    required this.onStartTap,
    required this.onRestartTap,
    required this.onPauseTap,
    required this.onResumeTap,
  }) {
    startButton = MyButton(
      onTap: _startButtonTap,
      text: "Start",
      position: position,
      size: Vector2(150, buttonHeight),
      textPos: Vector2(40, 15),
    );

    restartButton = MyButton(
      onTap: _restartButtonTap,
      text: "Restart",
      position: position,
      size: Vector2(180, buttonHeight),
      textPos: Vector2(30, 15),
    );

    pauseButton = MyButton(
      onTap: _pauseButtonTap,
      text: "Pause",
      position: position,
      size: Vector2(150, buttonHeight),
      textPos: Vector2(30, 15),
    );

    resumeButton = MyButton(
      onTap: _resumeButtonTap,
      text: "Resume",
      position: position,
      size: Vector2(180, buttonHeight),
      textPos: Vector2(25, 15),
    );

    lastShownButton = startButton;
  }

  Future<void> init() async {
    await _showStartButton();
  }

  Future<void> _startButtonTap() async {
    await _showPauseButton();
    onStartTap();
  }

  Future<void> _restartButtonTap() async {
    await _showPauseButton();
    onRestartTap();
  }

  Future<void> _pauseButtonTap() async {
    await _showResumeButton();
    onPauseTap();
  }

  Future<void> _resumeButtonTap() async {
    await _showPauseButton();
    onResumeTap();
  }

  Future<void> _showButton(MyButton button) async {
    _removeLastShowButton();
    if (!world.contains(button)) {
      await world.add(button);
    }
    lastShownButton = button;
  }

  Future<void> showRestartButton() async {
    await _showButton(restartButton);
  }
  Future<void> pause() async {
    await _pauseButtonTap();
  }

  Future<void> _showStartButton() async {
    await _showButton(startButton);
  }

  Future<void> _showPauseButton() async {
    await _showButton(pauseButton);
  }

  Future<void> _showResumeButton() async {
    await _showButton(resumeButton);
  }

  void _removeLastShowButton() {
    if (world.contains(lastShownButton)) {
      world.remove(lastShownButton);
    }
  }

}
