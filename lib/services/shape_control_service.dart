import 'dart:async';

class ShapeControlService {
  static final _instance = ShapeControlService._();
  ShapeControlService._();
  factory ShapeControlService() => _instance;

  final StreamController<ShapeControlEvent> _shapeControlEventStreamController = StreamController.broadcast();

  Stream<ShapeControlEvent> get shapeControlEventStream => _shapeControlEventStreamController.stream;

  void _fireButtonEvent(ShapeControlEvent shapeControlEvent) {
    _shapeControlEventStreamController.add(shapeControlEvent);
  }
  void fireRotatePressed() {
    _fireButtonEvent(ShapeControlEvent(rotatePressed: true));
  }
  void fireLeftPressed() {
    _fireButtonEvent(ShapeControlEvent(leftPressed: true));
  }
  void fireLeftLongPressed() {
    _fireButtonEvent(ShapeControlEvent(leftLongPressed: true));
  }
  void fireRightPressed() {
    _fireButtonEvent(ShapeControlEvent(rightPressed: true));
  }
  void fireRightLongPressed() {
    _fireButtonEvent(ShapeControlEvent(rightLongPressed: true));
  }
  void fireDownPressed() {
    _fireButtonEvent(ShapeControlEvent(downPressed: true));
  }
  void fireDownLongPressed() {
    _fireButtonEvent(ShapeControlEvent(downLongPressed: true));
  }
  void firePressedCompleted() {
    _fireButtonEvent(ShapeControlEvent());
  }

}

class ShapeControlEvent {
  final bool leftPressed;
  final bool leftLongPressed;
  final bool rightPressed;
  final bool rightLongPressed;
  final bool downPressed;
  final bool downLongPressed;
  final bool rotatePressed;

  ShapeControlEvent({
    this.leftPressed = false,
    this.leftLongPressed = false,
    this.rightPressed = false,
    this.rightLongPressed = false,
    this.downPressed = false,
    this.downLongPressed = false,
    this.rotatePressed = false,
  });

  @override
  String toString() {
    return '${DateTime.now()} ButtonPressedInfo{left: $leftPressed, right: $rightPressed, down: $downPressed, leftLong: $leftLongPressed, rightLong: $rightLongPressed, downLong: $downLongPressed, rotate: $rotatePressed}';
  }
}
