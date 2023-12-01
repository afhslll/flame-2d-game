import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_2d_game/components/level.dart';

class PixelAdventure extends FlameGame {
  late CameraComponent cam;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() {
    Level world = Level();
    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}
