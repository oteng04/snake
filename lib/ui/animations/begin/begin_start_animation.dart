import "dart:ui";

import "package:flame/flame.dart";
import "package:flame/sprite.dart";
import "package:flutter/material.dart" as material;

import "../base_animation.dart";

class BeginStartAnimation extends BaseAnimation {
  Vector2 startCenter = Vector2(50, 87.5);
  Vector2 endCenter = Vector2(50, 50);
  Vector2 startSize = Vector2(60, 15);
  Vector2 endSize = Vector2(100, 100);

  Color startColor = const Color(0xFFe9edc9);
  Color endColor = const Color(0xFFe9edc9);

  Image? _startImage;

  BeginStartAnimation() {
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.playing;
  }

  @override
  void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {
    if(frameIndex < animationLength) {
      final currentCenter = _getCurrentCenter();
      final currentSize = _getCurrentSize();
      final currentColor = _getCurrentColor();
      canvas.drawRect(
        Rect.fromCenter(center: Offset(toAbsoluteX(currentCenter.x, screenSize: screenSize), toAbsoluteY(currentCenter.y, screenSize: screenSize)),
                        width: toAbsoluteX(currentSize.x, screenSize: screenSize),
                        height: toAbsoluteY(currentSize.y, screenSize: screenSize)),
        Paint()
          ..color = currentColor,
      );

      final _startImage = this._startImage;
      if(_startImage != null) {
        Sprite sprite = Sprite(_startImage);
        sprite.render(
          canvas,
          position: Vector2(toAbsoluteX(startCenter.x - currentSize.x / 2, screenSize: screenSize), toAbsoluteY(startCenter.y - currentSize.y / 2, screenSize: screenSize)),
          size: Vector2(toAbsoluteX(currentSize.x / 0.75, screenSize: screenSize), toAbsoluteY(currentSize.y, screenSize: screenSize)),
          overridePaint: Paint()
            ..color = Color.fromARGB(((1 - frameIndex / animationLength) * 255).toInt(), 0, 0, 0)
        );
      }
    }
    else {
      material.debugPrint("Warning: BeginStartAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }

  Vector2 _getCurrentCenter() {
    Vector2 currentCenter = Vector2(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentCenter = startCenter;

      Vector2 eachFrameCenterOffset = (endCenter - startCenter) / stateChangingFrame.toDouble();
      currentCenter += eachFrameCenterOffset * frameIndex.toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentCenter = endCenter;
    }

    return currentCenter;
  }

  Vector2 _getCurrentSize() {
    Vector2 currentSize = Vector2(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentSize = startSize;

      Vector2 eachFrameChangedSize = Vector2(endSize.x - startSize.x, endSize.y - startSize.y) / stateChangingFrame.toDouble();
      currentSize += eachFrameChangedSize * frameIndex.toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentSize = endSize;
    }

    return currentSize;
  }


  Color _getCurrentColor() {
    Color currentColor = const Color(0x00000000);

    if(frameIndex <= stateChangingFrame) {
      double eachFrameChangedRed = (endColor.red - startColor.red) / stateChangingFrame.toDouble();
      double eachFrameChangedGreen = (endColor.green - startColor.green) / stateChangingFrame.toDouble();
      double eachFrameChangedBlue = (endColor.blue - startColor.blue) / stateChangingFrame.toDouble();

      currentColor = Color.fromARGB(
        startColor.alpha,
        startColor.red + (eachFrameChangedRed * frameIndex).round(),
        startColor.green + (eachFrameChangedGreen * frameIndex).round(),
        startColor.blue + (eachFrameChangedBlue * frameIndex).round(),
      );
    }
    else if(frameIndex <= animationLength - 1) {
      const endAlpha = 0;
      double eachFrameChangedAlpha = (endAlpha - startColor.alpha) / (animationLength - 1 - stateChangingFrame).toDouble();

      currentColor = Color.fromARGB(
        endColor.alpha + (eachFrameChangedAlpha * (frameIndex - stateChangingFrame)).round(),
        endColor.red,
        endColor.green,
        endColor.blue,
      );
    }

    return currentColor;
  }

  @override
  Future<void> loadResource() async {
    _startImage = await Flame.images.load("start.png");
  }
}
