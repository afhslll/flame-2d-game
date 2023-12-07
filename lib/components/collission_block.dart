import 'package:flame/components.dart';

class CollissionBlock extends PositionComponent {
  bool isPlatform;
  CollissionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
  }) : super() {
    // debugMode = true;
  }
}
