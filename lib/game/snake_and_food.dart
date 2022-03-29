import "dart:ui";

import "package:flame/flame.dart";
import "package:vector_math/vector_math_64.dart";

class SnakeAndFood {
  static List<Image> images = [];

  static List<Image> imagesWithStroke = [];
  static List<Image> imagesWithStrokeSnakeBody = [];
  static List<Image> imagesWithStrokeSnakeHead = [];
  static List<Image> imagesWithStrokeSnakeHead2 = [];
  static List<Image> imagesWithStrokeSnakeHead3 = [];
  static List<Image> imagesWithStrokeSnakeHead4 = [];
  static List<Image> imagesWithStrokeSnakeTail = [];
  static List<Image> imagesWithStrokeSnakeTail2 = [];
  static List<Image> imagesWithStrokeSnakeTail3 = [];
  static List<Image> imagesWithStrokeSnakeTail4 = [];
  int imageId;
  Vector2 position;

  Image get image => images[imageId];
  SnakeAndFood({required this.position, required this.imageId});

  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load("food/food3.png"));
      imagesWithStroke.add(await Flame.images.load("food/foodWithStroke3.png"));
      imagesWithStrokeSnakeBody.add(await Flame.images.load("snake/body.png"));
      imagesWithStrokeSnakeHead.add(await Flame.images.load("snake/head.png"));
      imagesWithStrokeSnakeTail.add(await Flame.images.load("snake/tail.png"));
      imagesWithStrokeSnakeHead2.add(await Flame.images.load("snake/head2.png"));
      imagesWithStrokeSnakeTail2.add(await Flame.images.load("snake/tail2.png"));
      imagesWithStrokeSnakeHead3.add(await Flame.images.load("snake/head3.png"));
      imagesWithStrokeSnakeTail3.add(await Flame.images.load("snake/tail3.png"));
      imagesWithStrokeSnakeHead4.add(await Flame.images.load("snake/head4.png"));
      imagesWithStrokeSnakeTail4.add(await Flame.images.load("snake/tail4.png"));
    }
  }


}
