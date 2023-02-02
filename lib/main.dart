import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tetris/constants/const.dart';
import 'package:tetris/tetris_game.dart';
import 'package:tetris/widgets/about_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = TetrisGame();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold (
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            aboutWidget: (BuildContext context, TetrisGame game) {
              return AboutWidget(game: game);
            }
          },
        ),
      ),
    ),
  );
}
