import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_2d_game/components/collission_block.dart';
import 'package:flame_2d_game/components/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollissionBlock> collissionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _spawningObjects();
    _addCollissions();

    return super.onLoad();
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          default:
        }
      }
    }
  }

  void _addCollissions() {
    final collissionLayer = level.tileMap.getLayer<ObjectGroup>('Collissions');

    if (collissionLayer != null) {
      for (final collission in collissionLayer.objects) {
        switch (collission.class_) {
          case 'Platform':
            final platform = CollissionBlock(
              position: Vector2(collission.x, collission.y),
              size: Vector2(collission.width, collission.height),
              isPlatform: true,
            );
            collissionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollissionBlock(
              position: Vector2(collission.x, collission.y),
              size: Vector2(collission.width, collission.height),
            );
            collissionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collissionBlocks = collissionBlocks;
  }
}
