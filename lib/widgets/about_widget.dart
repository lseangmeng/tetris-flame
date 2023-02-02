import 'package:flutter/material.dart';
import 'package:tetris/components/playing_frame.dart';
import 'package:tetris/components/next_shape_frame.dart';
import 'package:tetris/constants/const.dart';
import 'package:tetris/tetris_game.dart';

class AboutWidget extends StatelessWidget {
  final TetrisGame game;

  const AboutWidget({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        width: 480,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Container()),
                InkWell(
                  onTap: _removeOnTap,
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              "This game was created by Seangmeng Long (Lseangmeng@gmail.com) using Flutter Flame.\n\n"
              "Use left, right and down arrow key to move the falling shape left, right and down respectively.\n\n"
              "Use the up arrow key or the space key to rotate the falling shape or fire a block "
              "for the block gun shape.\n\n"
              "The block gun shape is a vertical shape with 4 blocks with the first 3 blocks are blinking. "
              "It fires a block each time the space key or up arrow key is pressed.\n\n"
            ),
          ],
        ),
      ),
    );
  }

  void _removeOnTap() {
    game.overlays.remove(aboutWidget);
  }
}
