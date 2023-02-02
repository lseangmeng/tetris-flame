class Score {
  int value;
  Score({this.value = 0});

  void increaseWithRowsCleared(int numRowsCleared) {
    int score = 0;
    for (int r = 1; r <= numRowsCleared; r++) {
      score++;
      value += score;
    }
  }

  void reset() {
    value = 0;
  }
}