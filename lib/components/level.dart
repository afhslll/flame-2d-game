import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_2d_game/components/background_tile.dart';
import 'package:flame_2d_game/components/checkpoint.dart';
import 'package:flame_2d_game/components/chicken.dart';
import 'package:flame_2d_game/components/collission_block.dart';
import 'package:flame_2d_game/components/fruit.dart';
import 'package:flame_2d_game/components/player.dart';
import 'package:flame_2d_game/components/saw.dart';
import 'package:flame_2d_game/pixel_adventure.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollissionBlock> collissionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
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
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
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

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }
}
