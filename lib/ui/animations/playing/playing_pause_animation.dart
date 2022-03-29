import "package:flutter/material.dart";

import "../base_animation.dart";

class PlayingPauseAnimation extends BaseAnimation {
  Vector2 startCenter = Vector2(6, 5);
  Vector2 endCenter = Vector2(50, 55);

  Vector2 startSize = Vector2(10, 7);
  Vector2 endSize = Vector2(80, 75);

  Color startColor = const Color(0xFFe9edc9);
  Color endColor = const Color(0xFFe9edc9);

  PlayingPauseAnimation(){
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.pause;
  }
  @override
  void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {
    if(frameIndex < animationLength) {
      final currentCenter = getCurrentCenter();
      final currentSize = getCurrentSize();
      final currentColor = getCurrentColor();
      canvas.drawRect(
        Rect.fromCenter(center: Offset(toAbsoluteX(currentCenter.x, screenSize: screenSize), toAbsoluteY(currentCenter.y, screenSize: screenSize)),
                        width: toAbsoluteX(currentSize.x, screenSize: screenSize),
                        height: toAbsoluteY(currentSize.y, screenSize: screenSize)),
        Paint()
          ..color = currentColor,
      );
    }
    else {
      debugPrint("Warning: PlayingPauseAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }
  Vector2 getCurrentCenter() {
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
  Vector2 getCurrentSize() {
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
  Color getCurrentColor() {
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
}
