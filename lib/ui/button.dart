import "dart:ui";

import "package:flame/sprite.dart";
import "package:flutter/material.dart" as material;
import "package:vector_math/vector_math_64.dart";

class Button {
  bool _tapDown = false;
  final Color _color;
  final Offset _center;
   final Size _size;
   final Color _downColor;
   final double _downSizeRatio = 0.9;
   Image? image;
   final double _imageWidthRatio;
   final double _imageHeightRatio;

  Button({
    Offset center = const Offset(0, 0),
    Size size = const Size(0, 0),
    Color color = material.Colors.yellow,
    Color? downColor,
    double imageWidthRatio = 0.5,
    double imageHeightRatio = 1.0,
    this.image,
  })
      :_center = center
  ,_size = size
  ,_color = color
  ,_downColor = downColor ?? color
  ,_imageWidthRatio = imageWidthRatio
  ,_imageHeightRatio = imageHeightRatio;

   void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {
    if(!_tapDown) {

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(_toAbsoluteWidth(_center.dx, screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
              width: _toAbsoluteWidth(_size.width, screenSize: screenSize),
              height: _toAbsoluteHeight(_size.height, screenSize: screenSize),
            ),

            const Radius.circular(25.0)),
        Paint()..color = _color);

       final image = this.image;
      if(image != null) {
        Sprite sprite = Sprite(image);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteWidth(_center.dx - (_size.width * _imageWidthRatio / 2), screenSize: screenSize), _toAbsoluteHeight(_center.dy - (_size.height * _imageHeightRatio / 2), screenSize: screenSize)),
          size: Vector2(_toAbsoluteWidth(_size.width * _imageWidthRatio, screenSize: screenSize), _toAbsoluteHeight(_size.height * _imageHeightRatio, screenSize: screenSize)),
        );
      }
    } else {
       final _downColor = this._downColor;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(_center.dx, screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
            width: _toAbsoluteWidth(_size.width * _downSizeRatio, screenSize: screenSize),
            height: _toAbsoluteHeight(_size.height * _downSizeRatio, screenSize: screenSize)),
        Paint()
          ..color = _downColor,
      );
       final image = this.image;
      if(image != null) {
        Sprite sprite = Sprite(image);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteWidth(_center.dx - (_size.width * _imageWidthRatio * _downSizeRatio / 2), screenSize: screenSize), _toAbsoluteHeight(_center.dy - (_size.height * _imageHeightRatio * _downSizeRatio / 2), screenSize: screenSize)),
          size: Vector2(_toAbsoluteWidth(_size.width * _imageWidthRatio * _downSizeRatio, screenSize: screenSize), _toAbsoluteHeight(_size.height * _imageHeightRatio * _downSizeRatio, screenSize: screenSize)),
        );
      }
    }
  }

   void tapDown() {
    _tapDown = true;
  }

   void tapUp() {
    _tapDown = false;
  }

   bool isOnButton(double x, double y) {
    if(_center.dx - _size.width / 2 <= x &&
        _center.dy - _size.height / 2 <= y &&
        _center.dx + _size.width / 2 >= x &&
        _center.dy + _size.height / 2 >= y) {
      return true;
    }

    return false;
  }

   double _toAbsoluteWidth(double relativeWidth, {required Vector2 screenSize}) {
    return screenSize.x * relativeWidth / 100.0;
  }

  double _toAbsoluteHeight(double relativeHeight, {required Vector2 screenSize}) {
    return screenSize.y * relativeHeight / 100.0;
  }
}
