import 'package:flutter/material.dart';
import 'package:tetris/components/playing_frame.dart';
import 'package:tetris/components/next_shape_frame.dart';
import 'package:tetris/constants/const.dart';
import 'package:tetris/tetris_game.dart';
import 'package:url_launcher/url_launcher.dart';

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
              "Use the up arrow key or the space key to\n "
              "  - Rotate the falling shape or fire a block,\n "
              "  - Fire a block for the block gun shape,\n"
              "   - Fire a bullet for the bullet gun shape.\n\n"
              "The block gun shape is a vertical shape with 4 blocks having the first 3 blocks blinking. "
              "It fires a block each time the space key or up arrow key is pressed.\n\n"
              "The bullet gun shape is a vertical shape with 4 blocks having the last block blinking. "
              "It fires a bullet each time the space key or up arrow key is pressed. "
              "The bullet removes a block it touches. After touching a block, the bullet will disappear.\n\n"
              "To see how the block gun and bullet gun look like, click the button below."
            ),
            ElevatedButton(onPressed: _buttonPressed, child: const Text("More"))
          ],
        ),
      ),
    );
  }

  void _removeOnTap() {
    game.overlays.remove(aboutWidget);
  }

  void _buttonPressed() {
    final Uri url = Uri.parse('https://docs.google.com/document/d/18r5Nv9yu102OWOPv_WCQAg6dFP5RFFA0E-1rsWZcVvk/edit?usp=sharing');
    launchUrl(url);
  }
}
