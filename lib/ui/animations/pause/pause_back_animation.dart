import "package:flutter/material.dart";
import "../base_animation.dart";

class PauseBackAnimation extends BaseAnimation {
  int fadeoutAnimationLength = 10;

  Vector2 startCenter = Vector2(50, 55);
  Vector2 endCenter = Vector2(6, 5);

  Vector2 startSize = Vector2(80, 75);
  Vector2 endSize = Vector2(10, 7);


  Color startColor = const Color(0xFFe9edc9);
  Color endColor = const Color(0xFFe9edc9);

  PauseBackAnimation() {
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.playing;
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
      debugPrint("Warning: PauseBackAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }

  Vector2 getCurrentCenter() {
    Vector2 currentCenter = Vector2(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentCenter = startCenter;
    }
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      currentCenter = startCenter;
      Vector2 eachFrameCenterOffset = (endCenter - startCenter) / (animationLength - 1 - stateChangingFrame - fadeoutAnimationLength).toDouble();
      currentCenter += eachFrameCenterOffset * (frameIndex - stateChangingFrame).toDouble();
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
    }
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      currentSize = startSize;
      Vector2 eachFrameChangedSize = Vector2(endSize.x - startSize.x, endSize.y - startSize.y) / (animationLength - 1 - stateChangingFrame - fadeoutAnimationLength).toDouble();
      currentSize += eachFrameChangedSize * (frameIndex - stateChangingFrame).toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentSize = endSize;
    }

    return currentSize;
  }


  Color getCurrentColor() {
    Color currentColor = const Color(0x00000000);

    if(frameIndex <= stateChangingFrame) {
      const startAlpha = 0;
      double eachFrameChangedAlpha = (startColor.alpha - startAlpha) / stateChangingFrame.toDouble();

      currentColor = Color.fromARGB(
        startAlpha + (eachFrameChangedAlpha * frameIndex).round(),
        startColor.red,
        startColor.green,
        startColor.blue,
      );
    }
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      double eachFrameChangedRed = (endColor.red - startColor.red) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();
      double eachFrameChangedGreen = (endColor.green - startColor.green) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();
      double eachFrameChangedBlue = (endColor.blue - startColor.blue) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();

      currentColor = Color.fromARGB(
        startColor.alpha,
        startColor.red + (eachFrameChangedRed * (frameIndex - stateChangingFrame)).round(),
        startColor.green + (eachFrameChangedGreen * (frameIndex - stateChangingFrame)).round(),
        startColor.blue + (eachFrameChangedBlue * (frameIndex - stateChangingFrame)).round(),
      );
    }
    else if(frameIndex <= animationLength - 1) {
      const endAlpha = 0;
      double eachFrameChangedAlpha = (endAlpha - endColor.alpha) / stateChangingFrame.toDouble();

      int currentAlpha = endColor.alpha + (eachFrameChangedAlpha * (frameIndex - stateChangingFrame - (animationLength - stateChangingFrame - fadeoutAnimationLength))).round();
      if(currentAlpha < 0) { // Just make sure
        currentAlpha = 0;
      }
      currentColor = Color.fromARGB(
        currentAlpha,
        endColor.red,
        endColor.green,
        endColor.blue,
      );
    }

    return currentColor;
  }
}
