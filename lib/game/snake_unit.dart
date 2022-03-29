import "dart:ui";

import "package:vector_math/vector_math_64.dart";

import "direction.dart";

class SnakeUnit {
  Vector2 position;
  Direction direction;
  Color color;

  SnakeUnit({Vector2? position, this.direction = Direction.north, this.color = const Color(0xFFd4a373)})
  :position = position != null ? position.clone() : Vector2(0, 0);

  void forward() {
    switch(direction) {
      case Direction.north: {
        --position.y;

        break;
      }

      case Direction.east: {
        ++position.x;

        break;
      }

      case Direction.south: {
        ++position.y;

        break;
      }

      case Direction.west: {
        --position.x;

        break;
      }
    }
  }
}
