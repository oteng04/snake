import "package:vector_math/vector_math_64.dart";

class GameMap {
  Vector2 size;
  GameMap({Vector2? size})
  :size = size ?? Vector2(0, 0);

  void setSize(Vector2 size) {
    this.size = size;
  }

  bool isPointInMap(Vector2 point) {
    if(point.x < 0 || point.x >= size.x || point.y < 0 || point.y >= size.y) {
      return false;
    }
    return true;
  }
}
