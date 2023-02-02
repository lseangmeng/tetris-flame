class Level {
  int value = 1;
  int numRowsClearedToNextLevel = 20;
  int rowsClearedSinceLastLevel = 0;
  Level({this.value = 1});

  void increaseWithRowsCleared(int rowsClearedCount) {
    rowsClearedSinceLastLevel += rowsClearedCount;
    if (rowsClearedSinceLastLevel >= numRowsClearedToNextLevel) {
      value++;
      rowsClearedSinceLastLevel -= numRowsClearedToNextLevel;
      numRowsClearedToNextLevel += 5;
    }
  }

  void reset() {
    value = 1;
    numRowsClearedToNextLevel = 20;
    rowsClearedSinceLastLevel = 0;
  }
}