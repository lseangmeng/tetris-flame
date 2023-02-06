import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tetris/components/about_button.dart';
import 'package:tetris/components/game_control_component.dart';
import 'package:tetris/components/playing_frame.dart';
import 'package:tetris/components/info_frame.dart';
import 'package:tetris/components/next_shape_frame.dart';
import 'package:tetris/components/shape_control_component.dart';
import 'package:tetris/components/sound_button.dart';
import 'package:tetris/constants/const.dart';
import 'package:tetris/services/shape_control_service.dart';
import 'package:tetris/services/my_sound_player.dart';
import 'package:tetris/services/shape_control_keyboard.dart';
import 'package:tetris/services/shape_def.dart';

import 'components/my_block.dart';

class TetrisGame extends FlameGame with KeyboardEvents, HasTappableComponents {
  GameState gameState = GameState.notPlaying;
  final TextComponent gameOverText = TextComponent();
  final world = World();

  late final PlayingFrame playingFrame;
  late final NextShapeFrame nextShapeFrame;
  late final InfoFrame infoFrame;
  late final ShapeControlComponent shapeControlComponent;
  late final GameControlComponent gameControlComponent;
  late final AboutButton aboutButton;
  late final SoundButton soundButton;
  final ShapeControlKeyboard _shapeControlKeyboard = ShapeControlKeyboard();

  Future<ShapeIndex> nextRandomShapeIndex() async {
    ShapeIndex nextShapeIndex = nextShapeFrame.getShapeIndex();
    nextShapeFrame.newRandomShape();
    return nextShapeIndex;
  }

  TetrisGame() {
    playingFrame = PlayingFrame(
      world: world,
      position: _GameConst.playingFrame,
      fallingSpeedPixelsPerSecond: startSpeedPixelsPerSecond,
      nextRandomShapeIndex: nextRandomShapeIndex,
      onShapeHitBottom: _onShapeHitBottom,
      buttonPressedInfoStream: ShapeControlService().shapeControlEventStream,
    );
    nextShapeFrame = NextShapeFrame(
      world: world,
      position: _GameConst.nextShapeFramePos,
    );
    infoFrame = InfoFrame(world: world, position: _GameConst.infoFramePos);
    ShapeControlService shapeControlService = ShapeControlService();
    shapeControlComponent =
        ShapeControlComponent(_GameConst.shapeControlPos, shapeControlService);
    gameControlComponent = GameControlComponent(
      world: world,
      position: _GameConst.gameControlPos,
      onStartTap: _startOnTap,
      onRestartTap: _restartOnTap,
      onPauseTap: _pauseOnTap,
      onResumeTap: _resumeOnTap,
    );
    aboutButton = AboutButton(
      position: _GameConst.aboutButtonPos,
      world: world,
      onTap: _aboutOnTap,
    );
    soundButton = SoundButton(
      position: _GameConst.soundButtonPos,
      world: world,
    );
  }

  @override
  Color backgroundColor() => const Color(0x20e2d3d0);

  @override
  Future<void> onLoad() async {
    const TextStyle style = TextStyle(color: Color(0xffff0000), fontSize: 40);
    gameOverText
      ..text = ""
      ..textRenderer = TextPaint(style: style)
      ..position = _GameConst.gameOverPos;

    await playingFrame.init();
    await nextShapeFrame.init();
    await infoFrame.init();
    await shapeControlComponent.init(world);
    await gameControlComponent.init();
    await aboutButton.init();
    await soundButton.init();

    await world.add(gameOverText);
    await add(world);

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(_GameConst.gameWidth, _GameConst.gameHeight)
      ..viewfinder.position = Vector2(_GameConst.gameWidth / 2, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    await add(camera);

    await MySoundPlayer.init();
  }

  void _resumeOnTap() {
    debugPrint("Resume onTap");
    gameState = GameState.playing;
    playingFrame.resume();
    resumeEngine();
  }

  Future<void> _aboutOnTap() async {
    if (gameState == GameState.playing) {
      await gameControlComponent.pause();
    }
    overlays.add(aboutWidget);
  }

  Future<void> _pauseOnTap() async {
    debugPrint("Pause onTap");
    if (gameState == GameState.pause) {
      debugPrint("Already paused. Skip");
      return;
    }
    gameState = GameState.pause;
    await playingFrame.pause();
    await waitUntilUpdateWasShownOnScreen();
    pauseEngine();
  }

  Future<void> waitUntilUpdateWasShownOnScreen() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _restartOnTap() async {
    debugPrint("Restart onTap");
    gameState = GameState.playing;
    gameOverText.text = "";
    ShapeDef().setToHardMode();
    playingFrame.restart();
    infoFrame.restart();
    resumeEngine();
  }

  void _startOnTap() {
    debugPrint("Start onTap");
    gameState = GameState.playing;
    playingFrame.start();
  }

  @override
  void update(double dt) {
    if (gameState == GameState.playing) {
      // _handleButtonEvent();
      playingFrame.update(dt);
    }
    super.update(dt);
  }

  void _onShapeHitBottom(
      GameState gameState, int rowClearedCount, int highestHeight) {
    if (gameState == GameState.gameOver) {
      _gameOver();
    } else {
      if (rowClearedCount > 0) {
        infoFrame.updateScoreAndLevel(rowClearedCount);
      }
      if (highestHeight <= PlayingFrame.rowCount * 3 / 5 + 1) {
        ShapeDef().setToHardMode();
      } else if (highestHeight <= PlayingFrame.rowCount * 4 / 5) {
        ShapeDef().setToMediumMode();
      } else {
        ShapeDef().setToEasyMode();
      }
    }
  }

  Future<void> _gameOver() async {
    gameControlComponent.showRestartButton();
    gameOverText.text = "Game Over";
    await Future.delayed(const Duration(milliseconds: 100));
    pauseEngine();
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (gameState != GameState.playing) return KeyEventResult.ignored;

    _shapeControlKeyboard.onKeyEvent(event, keysPressed);

    final isKeyDown = event is RawKeyDownEvent;

    if (isKeyDown) {
      // for debugging
      // if (keysPressed.contains(LogicalKeyboardKey.keyB)) {
      //   ShapeDef().toggleOnlyBulletGunShape();
      // }
      // if (keysPressed.contains(LogicalKeyboardKey.keyO)) {
      //   ShapeDef().toggleOnlyBlockGunShape();
      // }
      // if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      //   ShapeDef().toggleOnlySpecialOneBlock();
      // }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class _GameConst {
  static const double frameTopGap = MyBlock.blockHeight * 4;
  static const double frameGap = 10;
  static final Vector2 playingFrame = Vector2(frameGap, frameTopGap);
  static final Vector2 nextShapeFramePos =
      playingFrame + Vector2(PlayingFrame.width + frameGap, 0);
  static final Vector2 gameOverPos = nextShapeFramePos + Vector2(40, -60);
  static final Vector2 infoFramePos =
      nextShapeFramePos + Vector2(0, NextShapeFrame.height + frameGap);
  static final Vector2 shapeControlPos =
      infoFramePos + Vector2(0, InfoFrame.height + frameGap);
  static final Vector2 gameControlPos =
      playingFrame + Vector2(0, PlayingFrame.height + frameGap);
  static final Vector2 aboutButtonPos = gameControlPos + Vector2(250, 0);
  static final Vector2 soundButtonPos = aboutButtonPos + Vector2(200, 0);

  static const double gameWidth =
      PlayingFrame.width + NextShapeFrame.width + frameGap * 3;
  static const double gameHeight =
      frameTopGap + PlayingFrame.height + frameGap * 3 + buttonHeight;
}
