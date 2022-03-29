import "package:flutter/material.dart";
import "package:vector_math/vector_math_64.dart";
export "package:vector_math/vector_math_64.dart";

import "../../../game/game_state.dart";
export "../../../game/game_state.dart";


class BaseAnimation {
   int animationLength = 0;
    int stateChangingFrame = -1;
   GameState? targetGameState;

   int frameIndex = 0;

  void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {

  }

   bool haveNextFrame() {
    return frameIndex < (animationLength - 1);
  }

  bool toNextFrame() {
     if(haveNextFrame()) {
      frameIndex ++;
      return true;
    }

    return false;
  }
  void reset() {
    frameIndex = 0;
  }

  bool isStateChangingFrame() {
    return frameIndex == stateChangingFrame;
  }

  GameState? getTargetGameState() {
    return targetGameState;
  }

  Future<void>? loadResource() => null;

  @protected
  double toAbsoluteX(double relativeX, {required Vector2 screenSize}) {
    return screenSize.x * relativeX / 100.0;
  }

  @protected
  double toAbsoluteY(double relativeY, {required Vector2 screenSize}) {
    return screenSize.y * relativeY / 100.0;
  }
}
