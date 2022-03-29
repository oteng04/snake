import "dart:math";
import "dart:ui";

import "package:flutter/material.dart" as material;
import "package:vector_math/vector_math_64.dart";

import '../game.dart';
import "direction.dart";
import "snake_and_food.dart";
import "game_map.dart";
import "snake.dart";

class SnakeGame {
  Vector2 gameAreaSize = Vector2(98, 89);

  late Vector2 gameAreaOffset;

  Color gameAreaColor = const Color(0xFF333333);

  late GameMap gameMap;
  late Snake snake;
  late SnakeAndFood snakeAndFood;
  int currentScore = 0;

  SnakeGame({required Vector2 mapSize}) {
    gameAreaOffset = Vector2(99, 99) - gameAreaSize;
    gameMap = GameMap(size: mapSize);
    snake = Snake(
        spawnPoint:
            Vector2((mapSize.x ~/ 2).toDouble(), (mapSize.y ~/ 2).toDouble()));
    reset();
  }

  static get size => null;

  static Future<void> loadResource() async {
    SnakeAndFood.loadResource();
   }

  void flexilizeGameArea({required Vector2 screenSize}) {
    double topOffset = 10;
    if (screenSize.y * (100 - topOffset) / 100 > screenSize.x) {
      double minimumGameMapUnitSize =
          screenSize.y * (100 - topOffset) / 100 / gameMap.size.y;
      double gameMapUnitSize = screenSize.x / gameMap.size.x;
      gameMapUnitSize = gameMapUnitSize > minimumGameMapUnitSize
          ? minimumGameMapUnitSize
          : gameMapUnitSize;
      gameAreaSize = Vector2(
          _toRelativeX(gameMap.size.x * gameMapUnitSize,
              screenSize: screenSize),
          _toRelativeY(gameMap.size.y * gameMapUnitSize,
              screenSize: screenSize));
    } else {
      double gameMapUnitSize =
          screenSize.y * (100 - topOffset) / 100 / gameMap.size.y;
      gameAreaSize = Vector2(
          _toRelativeX(gameMap.size.x * gameMapUnitSize,
              screenSize: screenSize),
          _toRelativeY(gameMap.size.y * gameMapUnitSize,
              screenSize: screenSize));
    }

    gameAreaOffset = Vector2((100 - gameAreaSize.x) / 2,
        (100 - gameAreaSize.y - topOffset) / 2 + topOffset);
  }

  Vector2 getMapUnitSize({required Vector2 screenSize}) {
    Vector2 mapUnitSize = Vector2(
      _toAbsoluteX(gameAreaSize.x, screenSize: screenSize) / gameMap.size.x,
      _toAbsoluteY(gameAreaSize.y, screenSize: screenSize) / gameMap.size.y,
    );
    return mapUnitSize;
  }

  void reset() {
    snake.reset();
    snake.forwardAndGrow(color: const Color(0xFF32CD32));
    snake.forwardAndGrow(color: const Color(0xFF32CD32));
    createNewFood();

    currentScore = 0;
  }

  bool canForwardSnake() {
    final targetPoint = snake.getTargetPoint();

    if (snake.isPointOnBody(targetPoint)) {
      return false;
    }
    else if (!gameMap.isPointInMap(targetPoint)) {
      return false;
    }
    return true;
  }

  void forwardSnake() {
    final targetPoint = snake.getTargetPoint();

    // Touch a food
    if (targetPoint.x == snakeAndFood.position.x && targetPoint.y == snakeAndFood.position.y) {
      snake.forwardAndGrow(color: const Color(0xFF32CD32));
      createNewFood();
      ++currentScore;
      material.debugPrint("currentScore: " + currentScore.toString());
    }
    else {
      snake.forward();
    }
  }

  bool isSnakeFacingFood() {
    final targetPoint = snake.getTargetPoint();
    if (targetPoint.x == snakeAndFood.position.x && targetPoint.y == snakeAndFood.position.y) {
      return true;
    }
    return false;
  }

  void moveSnakeTo(Vector2 point) {
    return snake.moveTo(point);
  }

  void turnSnake(Direction direction) {
    return snake.turn(direction);
  }
  bool createNewFood() {
    if (snake.length >= gameMap.size.x * gameMap.size.y) {
      return false;
    }

    Vector2 position = Vector2(0, 0);
    do {
      position = Vector2(Random().nextInt(gameMap.size.x.toInt()).toDouble(),
          Random().nextInt(gameMap.size.y.toInt()).toDouble());
    } while (snake.isPointOnBody(position));
    int imageId;
    do {
      imageId = Random().nextInt(5);
    } while (!GameMain.enabledFood[imageId]);
    snakeAndFood = SnakeAndFood(position: position, imageId: imageId);
    return true;
  }

  double _toAbsoluteX(double relativeX, {required Vector2 screenSize}) {
    return screenSize.x * relativeX / 100.0;
  }

  double _toAbsoluteY(double relativeY, {required Vector2 screenSize}) {
    return screenSize.y * relativeY / 100.0;
  }

  double _toRelativeX(double absoluteX, {required Vector2 screenSize}) {
    return absoluteX * 100.0 / screenSize.x;
  }

  double _toRelativeY(double absoluteY, {required Vector2 screenSize}) {
    return absoluteY * 100.0 / screenSize.y;
  }
}
