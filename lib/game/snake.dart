import "dart:ui";

import "package:flutter/material.dart" as material;
import "package:vector_math/vector_math_64.dart";

import "direction.dart";
import "snake_unit.dart";

class Snake {
  Vector2 _spawnPoint;

  List<SnakeUnit> _body;

  bool _alive;

  Snake({Vector2? spawnPoint})
  :_body = []
  ,_spawnPoint = spawnPoint ?? Vector2(0, 0)
  ,_alive = true
  {
    _body.add(SnakeUnit(position: _spawnPoint, direction: Direction.north, color: const Color(0xFFd4a373)));
  }

  List<SnakeUnit  > get body => _body;

  int get length => _body.length;

  void reset() {
    _body = [];
    _body.add(SnakeUnit(position: _spawnPoint, direction: Direction.north, color: const Color(0xFFd4a373)));
    _body.add(SnakeUnit(position: _spawnPoint, direction: Direction.north, color: const Color(0xFFd4a373)));
    _alive = true;
  }

  void setSpawnPoint(Vector2 spawnPoint) {
    _spawnPoint = spawnPoint;
  }

  void moveTo(Vector2 position) {
    _body[0].position = position.clone();
    for(int i = 1; i < _body.length; ++i) {
      _body[i].forward();
      _body[i].direction = _body[i-1].direction;
    }
  }

  void moveToAndGrow(Vector2 position, {Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(color: const Color(0xFFd4a373));
    newTail.position = _body.last.position.clone();
    newTail.direction = _body.last.direction;

    moveTo(position);
    _body.add(newTail);
  }

  void forward() {
    for(int i = _body.length - 1; i > 0; --i) {
      _body[i].position = _body[i-1].position.clone();
      _body[i].direction = _body[i-1].direction;
    }
    _body.first.forward();
  }

  void forwardAndGrow({Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(color: const Color(0xFFd4a373));
    newTail.position = _body.last.position.clone();
    newTail.direction = _body.last.direction;

    forward();
    _body.add(newTail);
  }

  void turn(Direction direction) {
    if(_body.length > 1) {
      switch(direction) {
        case Direction.north: {
          if(_body.first.position.y > _body[1].position.y) {
            material.debugPrint("Failed to turn north");
            return;
          }
          break;
        }
        case Direction.east: {
          if(_body.first.position.x < _body[1].position.x) {
            material.debugPrint("Failed to turn east");
            return;
          }
          break;
        }
        case Direction.south: {
          if(_body.first.position.y < _body[1].position.y) {
            material.debugPrint("Failed to turn south");
            return;
          }
          break;
        }
        case Direction.west: {
          if(_body.first.position.x > _body[1].position.x) {
            material.debugPrint("Failed to turn west");
            return;
          }
          break;
        }
      }
    }
    material.debugPrint("snake.body.length = ${_body.length}");
    _body[0].direction = direction;
  }

  bool isAlive() {
    return _alive;
  }

  bool isPointOnBody(Vector2 position) {
    for(SnakeUnit snakeUnit in _body) {
      if(snakeUnit.position == position) {
        return true;
      }
    }

    return false;
  }

   Vector2 getTargetPoint() {
    final snakeHead = _body.first;
    var targetPoint = Vector2(snakeHead.position.x, snakeHead.position.y);
    switch(snakeHead.direction) {
      case Direction.north: {
        --targetPoint.y;
        break;
      }
      case Direction.east: {
        ++targetPoint.x;
        break;
      }
      case Direction.south: {
        ++targetPoint.y;
        break;
      }
      case Direction.west: {
        --targetPoint.x;
        break;
      }
    }

    return targetPoint;
  }
}
