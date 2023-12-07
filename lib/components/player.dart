import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_2d_game/components/collission_block.dart';
import 'package:flame_2d_game/components/custom_hitbox.dart';
import 'package:flame_2d_game/components/utils.dart';
import 'package:flame_2d_game/pixel_adventure.dart';
import 'package:flutter/services.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    super.position,
    this.character = 'Ninja Frog',
  });

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  List<CollissionBlock> collissionBlocks = [];
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      _updatePlayerState();
      _updatePlayerMovement();
      _checkHorizontalCollissions();
      _applyGravity();
      _checkVerticalCollissions();

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    fallingAnimation = _spriteAnimation('Fall', 1);
    jumpingAnimation = _spriteAnimation('Jump', 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.jumping: jumpingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // Check if falling, set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Check if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement() {
    if (hasJumped && isOnGround) _playerJump();

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * fixedDeltaTime;
  }

  void _playerJump() {
    velocity.y = -_jumpForce;
    position.y += velocity.y * fixedDeltaTime;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollissions() {
    for (final block in collissionBlocks) {
      if (!block.isPlatform) {
        if (checkCollission(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity() {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * fixedDeltaTime;
  }

  void _checkVerticalCollissions() {
    for (final block in collissionBlocks) {
      if (block.isPlatform) {
        if (checkCollission(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.offsetY - hitbox.height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollission(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
}
