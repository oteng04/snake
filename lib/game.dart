import "dart:math";
import "dart:ui";


import "package:flame/flame.dart";
import "package:flame/game.dart";
import "package:flame/input.dart";
import "package:flame/sprite.dart";
import "package:flutter/material.dart" as material;
import "package:flutter/services.dart";
import "package:flutter/widgets.dart" as widgets;
import 'package:snakegame/game/snake_and_food.dart';

import "game/direction.dart";
import "game/snake_game.dart";
import "ui/animations.dart";
import "ui/button.dart";

class GameMain with Loadable, Game, TapDetector, KeyboardEvents {

  static Image? _foodImage;

  static Image? _numberInfImage;
  static Image? _numberUnknownImage;
  static final List<Image> _gameOverImages = [];
  static final List<Image> _numberImages = [];
  static Image? _scoreImage;
  final SnakeGame _snakeGame = SnakeGame(mapSize: Vector2(21, 35));
  Vector2? _screenSize;

  GameState _gameState = GameState.begin;

  final Map<GameState, Map<String, Button>> _buttons = {
    for (var value in GameState.values) value: {}
  };

  final Map<GameState, Map<String, BaseAnimation>> _animations = {
    for (var value in GameState.values) value: {}
  };

  String? _tappingButtonName;
  BaseAnimation? _playingAnimation;
  static double _snakeForwardTime = 0.35;
  double _snakeForwardTimer = 0;
  static List<bool> enabledFood = [true, true, true, true, true];


  int _gameOverImageFrame = 0;
  final int _gameOverImageCount = 3;
  final int _gameOverImageChangeFrame = 20;

  @override
  void onTapDown(TapDownInfo info) {
    if (_playingAnimation != null) {
      return;
    }

    if (_screenSize == null) {
      material.debugPrint("onTapDown(): Error! _screenSize is null");
      return;
    }

    final x = _toRelativeX(info.eventPosition.game.x);
    final y = _toRelativeY(info.eventPosition.game.y);

    _buttons[_gameState]!.forEach((key, value) => {
      if (value.isOnButton(x, y))
        {
          material.debugPrint("$key button tap down"),
          value.tapDown(),
          _tappingButtonName = key,
        }
    });
  }

  @override
  void onTapUp(TapUpInfo info) {

    if (_screenSize == null) {
      material.debugPrint("onTapUp(): Error! _screenSize is null");
      return;
    }

    final x = _toRelativeX(info.eventPosition.game.x);
    final y = _toRelativeY(info.eventPosition.game.y);
    material.debugPrint("Tap up on ($x, $y)");

    final tappingButton = _buttons[_gameState]![_tappingButtonName];

    if (tappingButton != null) {
      material.debugPrint("$_tappingButtonName button tapped");

      final animationName = _tappingButtonName;
      final playingAnimation = _animations[_gameState]![animationName];
      if (playingAnimation != null) {
        _playingAnimation = playingAnimation;
      }

      tappingButton.tapUp();
      _tappingButtonName = null;
    }


  }

  @override
  void onTapCancel() {
    final tappingButton = _buttons[_gameState]![_tappingButtonName];
    if (tappingButton != null) {
      tappingButton.tapUp();
      _tappingButtonName = null;
    }
  }


  @override
  widgets.KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_playingAnimation != null) {
      return widgets.KeyEventResult.ignored;
    }

    if (event is RawKeyDownEvent) {
      if (_gameState == GameState.playing) {
        if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
            keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
          _snakeGame.turnSnake(Direction.north);
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
          _snakeGame.turnSnake(Direction.east);
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
            keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
          _snakeGame.turnSnake(Direction.south);
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
          _snakeGame.turnSnake(Direction.west);
        }
        if (keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[_gameState]!["pause"];
         }
      }
      else if (_gameState == GameState.pause) {
        if (keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[_gameState]!["back"];
         }
      }

      return widgets.KeyEventResult.handled;
    }

    return widgets.KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad(); // @mustCallSuper



    SnakeGame.loadResource();
      _numberInfImage = await Flame.images.load("number/numberInf.png");
    _numberUnknownImage = await Flame.images.load("number/numberUnknown.png");
    _scoreImage = await Flame.images.load("score.png");
    for (int i = 0; i < _gameOverImageCount; ++i) {
      _gameOverImages.add(await Flame.images.load("gameOver$i.png"));
    }

    for (int i = 0; i <= 9; ++i) {
      _numberImages.add(await Flame.images.load("number/number$i.png"));
    }

    _buttons[GameState.begin]!["start"] = Button(
      center: const Offset(50, 67.5),
      size: const Size(30, 10.5),
      color: const Color(0xFFe9edc9),
      downColor: const Color(0xFFe9edc9),
      image: await Flame.images.load("start.png"),
      imageWidthRatio: 0.5,
    );




    _buttons[GameState.playing]!["pause"] = Button(
      center: const Offset(6, 5),
      size: const Size(10, 7),
      color: const Color(0xFFe9edc9),
      downColor: const Color(0xFFe9edc9),
      image: await Flame.images.load("pause.png"),
      imageWidthRatio: 0.75,
    );

     _buttons[GameState.pause]!["back"] = Button(
      center: const Offset(82, 23),
      size: const Size(10, 7),
      color: const Color(0xFFe9edc9),
      downColor: const Color(0xFFe9edc9),
      image: await Flame.images.load("back.png"),
      imageWidthRatio: 0.75,
    );


    _buttons[GameState.gameOver]!["retry"] = Button(
      center: const Offset(50, 87.5),
      size: const Size(25, 12.5),
      color: const Color(0xFFe9edc9),
      downColor: const Color(0xFFe9edc9),
      image: await Flame.images.load("retry.png"),
      imageWidthRatio: 0.75,
    );

    _animations[GameState.begin]!["start"] = BeginStartAnimation()
      ..loadResource();


    _animations[GameState.playing]!["pause"] = PlayingPauseAnimation()
      ..loadResource();
    _animations[GameState.playing]!["gameOver"] = PlayingGameOverAnimation()
      ..loadResource();

    _animations[GameState.pause]!["back"] = PauseBackAnimation()
      ..loadResource();
    _animations[GameState.pause]!["home"] = PauseHomeAnimation()
      ..loadResource();
    _animations[GameState.pause]!["gameOver"] = PauseGameOverAnimation()
      ..loadResource();

     _animations[GameState.gameOver]!["retry"] = GameOverRetryAnimation()
      ..loadResource();
  }

  @override
  void onMount() {
    final _screenSize = this._screenSize;
    if (_screenSize != null) {
      _snakeGame.flexilizeGameArea(screenSize: _screenSize);
    } else {
      material.debugPrint(
          "null");
    }
  }

  @override
  void render(Canvas canvas) {
    switch (_gameState) {
      case GameState.begin:
        {
          _drawBeginScreen(canvas);

          break;
        }


      case GameState.playing:
        {
          _drawPlayingScreen(canvas);

          break;
        }

      case GameState.pause:
        {
          _drawPlayingScreen(canvas);
          _drawPauseMenu(canvas);

          break;
        }

      case GameState.gameOver:
        {
          _drawGameOverScreen(canvas);

          break;
        }
    }

    _drawAnimation(canvas);
  }

  @override
  void update(double updateTime) {
     if (_gameState == GameState.begin) {
       int imageId;
      do {
        imageId = Random().nextInt(5);
      } while (!enabledFood[imageId]);


    }


    final playingAnimation = _playingAnimation;
    if (playingAnimation != null) {
      if (playingAnimation.isStateChangingFrame()) {
        if (_playingAnimation == _animations[GameState.begin]!["start"] ||
            _playingAnimation == _animations[GameState.gameOver]!["retry"]) {
          _setStartGame();
        } else if (_playingAnimation ==
            _animations[GameState.pause]!["gameOver"]) {
          _setGameOver();
        }

        final targetGameState = playingAnimation.getTargetGameState();
        if (targetGameState != null) {
          _gameState = targetGameState;
        }
      }

      if (playingAnimation.haveNextFrame()) {
        playingAnimation.toNextFrame();
      } else {
        playingAnimation.reset();
        _playingAnimation = null;
      }

      return;
    }

    if (_gameState == GameState.playing) {
      _snakeForwardTimer += updateTime;
      if (_snakeForwardTimer >= _snakeForwardTime) {
        _snakeForwardTimer = 0;
        if (_snakeGame.canForwardSnake()) {

          _snakeGame.forwardSnake();
        }
        else {
          _setGameOver();
        }
      }
    }
  }

  @override
  void onGameResize(Vector2 screenSize) {
    _screenSize = screenSize;

    _snakeGame.flexilizeGameArea(screenSize: screenSize);
  }

  double _toRelativeX(double absoluteX) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      material
          .debugPrint("PixelSnake::_toRelativeX(): Error! _screenSize is null");
      return 0;
    }

    return absoluteX / _screenSize.x * 100.0;
  }

  double _toRelativeY(double absoluteY) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      material
          .debugPrint("PixelSnake::_toRelativeY(): Error! _screenSize is null");
      return 0;
    }

    return absoluteY / _screenSize.y * 100.0;
  }
  double _toAbsoluteX(double relativeX) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      material
          .debugPrint("PixelSnake::_toAbsoluteX(): Error! _screenSize is null");
      return 0;
    }

    return relativeX * _screenSize.x / 100.0;
  }

  double _toAbsoluteY(double relativeY) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      material
          .debugPrint("PixelSnake::_toAbsoluteY(): Error! _screenSize is null");
      return 0;
    }

    return relativeY * _screenSize.y / 100.0;
  }
  void _drawBeginScreen(Canvas canvas) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()..color = const Color(0XFFd4a373),
    );
    _buttons[GameState.begin]!.forEach(
            (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize));
  }

  void _drawSettingScreen(Canvas canvas) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()..color = const Color(0XFFd4a373),
    );

    if (_foodImage != null) {
      Sprite sprite = Sprite(_foodImage!);
      sprite.render(canvas,
          position: Vector2(_toAbsoluteX(5), _toAbsoluteY(69)),
          size: Vector2(_toAbsoluteX(20), _toAbsoluteY(7.5)),
          overridePaint: Paint()..color = const Color.fromARGB(150, 0, 0, 0));
    }

  }

  void _drawPlayingScreen(Canvas canvas) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()..color = const Color(0xFFd4a373),
    );


    int currentScore = _snakeGame.currentScore;



    canvas.drawRect(
      Rect.fromLTWH(
        _toAbsoluteX(_snakeGame.gameAreaOffset.x),
        _toAbsoluteY(_snakeGame.gameAreaOffset.y),
        _toAbsoluteX(_snakeGame.gameAreaSize.x),
        _toAbsoluteY(_snakeGame.gameAreaSize.y),
      ),
      Paint()..color = const Color(0xFFe9edc9));

    final mapUnitSize = _snakeGame.getMapUnitSize(screenSize: _screenSize);
    Sprite sprite = Sprite(SnakeAndFood.imagesWithStroke[_snakeGame.snakeAndFood.imageId]);
    sprite.render(
      canvas,
      position: Vector2(
          _snakeGame.snakeAndFood.position.x * mapUnitSize.x +
              _toAbsoluteX(_snakeGame.gameAreaOffset.x),
          _snakeGame.snakeAndFood.position.y * mapUnitSize.y +
              _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
      size: Vector2(mapUnitSize.x, mapUnitSize.y),
    );

    for (int i = 1; i <  _snakeGame.snake.body.length -1; i++) {
      if(i != 0 || i!=  _snakeGame.snake.body.length -1) {
        canvas.drawRect(
          Rect.fromLTWH(
            _snakeGame.snake.body[i].position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),
            _snakeGame.snake.body[i].position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y),
            mapUnitSize.x,
            mapUnitSize.y,
          ),
          Paint()
            ..color = _snakeGame.snake.body[i].color,
        );

        Sprite sprite = Sprite(
            SnakeAndFood.imagesWithStrokeSnakeBody[_snakeGame.snakeAndFood.imageId]);

        sprite.render(
          canvas,
          position: Vector2(_snakeGame.snake.body[i].position.x * mapUnitSize.x +
              _toAbsoluteX(_snakeGame.gameAreaOffset.x),
              _snakeGame.snake.body[i].position.y * mapUnitSize.y +
                  _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
          size: Vector2(mapUnitSize.x, mapUnitSize.y),
        );
      }

    }

    final snakeHead = _snakeGame.snake.body.first;
    final snakeTail = _snakeGame.snake.body.last;
    Vector2 headSize = Vector2(mapUnitSize.x, mapUnitSize.y);
    Vector2 tailSize = Vector2(mapUnitSize.x, mapUnitSize.y);
    Sprite sprite1 = Sprite(SnakeAndFood.imagesWithStrokeSnakeHead[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite11 = Sprite(SnakeAndFood.imagesWithStrokeSnakeHead2[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite111 = Sprite(SnakeAndFood.imagesWithStrokeSnakeHead3[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite1111 = Sprite(SnakeAndFood.imagesWithStrokeSnakeHead4[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite2 = Sprite(SnakeAndFood.imagesWithStrokeSnakeTail[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite22 = Sprite(SnakeAndFood.imagesWithStrokeSnakeTail2[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite222= Sprite(SnakeAndFood.imagesWithStrokeSnakeTail3[_snakeGame.snakeAndFood.imageId]);
    Sprite sprite2222 = Sprite(SnakeAndFood.imagesWithStrokeSnakeTail4[_snakeGame.snakeAndFood.imageId]);
    switch (snakeHead.direction) {
      case Direction.north:
        {

           break;
        }
      case Direction.east:
        {
            sprite11.render(
            canvas,
            position: Vector2(snakeHead.position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeHead.position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
            size: Vector2(mapUnitSize.x, mapUnitSize.y,),

          );
            sprite22.render(
              canvas,
              position: Vector2(snakeTail.position.x * mapUnitSize.x +
                  _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeTail.position.y * mapUnitSize.y +
                  _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
              size: Vector2(mapUnitSize.x, mapUnitSize.y,),

            );
           headSize = Vector2(0,0);
            tailSize = Vector2(0,0);
          break;

        }
      case Direction.south:
        {
          sprite111.render(
            canvas,
            position: Vector2(snakeHead.position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeHead.position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
            size: Vector2(mapUnitSize.x, mapUnitSize.y,),

          );
          sprite222.render(
            canvas,
            position: Vector2(snakeTail.position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeTail.position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
            size: Vector2(mapUnitSize.x, mapUnitSize.y,),

          );
          headSize = Vector2(0,0);
          tailSize = Vector2(0,0);
          break;
        }
      case Direction.west:
        {
          sprite1111.render(
            canvas,
            position: Vector2(snakeHead.position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeHead.position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
            size: Vector2(mapUnitSize.x, mapUnitSize.y,),

          );
          sprite2222.render(
            canvas,
            position: Vector2(snakeTail.position.x * mapUnitSize.x +
                _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeTail.position.y * mapUnitSize.y +
                _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
            size: Vector2(mapUnitSize.x, mapUnitSize.y,),

          );
          headSize = Vector2(0,0);
          tailSize = Vector2(0,0);
          break;
        }
    }


    sprite1.render(
      canvas,
      position: Vector2(snakeHead.position.x * mapUnitSize.x +
          _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeHead.position.y * mapUnitSize.y +
          _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
      size: headSize,

    );


    sprite2.render(
      canvas,
      position: Vector2(snakeTail.position.x * mapUnitSize.x +
          _toAbsoluteX(_snakeGame.gameAreaOffset.x),    snakeTail.position.y * mapUnitSize.y +
          _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
      size: tailSize,
    );
    _buttons[GameState.playing]!.forEach(
            (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize));
  }

  void _drawPauseMenu(Canvas canvas) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }


    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(_toAbsoluteX(10), _toAbsoluteY(17.5), _toAbsoluteX(80),
                _toAbsoluteY(75)),

            const Radius.circular(25.0)),
        Paint()..color = const Color(0xFF111111),);    // Draw volume title


        {
      Vector2 handleSize = Vector2(3, 6);


    }

    _buttons[GameState.pause]!.forEach(
            (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize));
  }

  void _drawGameOverScreen(Canvas canvas) {
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()..color = const Color(0xFFd4a373),
    );

    if (_gameOverImageFrame >=
        _gameOverImageCount * _gameOverImageChangeFrame) {
      _gameOverImageFrame = 0;
    }
    Sprite sprite = Sprite(
        _gameOverImages[_gameOverImageFrame ~/ _gameOverImageChangeFrame]);
    sprite.render(
      canvas,
      position: Vector2(_toAbsoluteX(20), _toAbsoluteY(5)),
      size: Vector2(_toAbsoluteX(60), _toAbsoluteY(30)),
    );
    ++_gameOverImageFrame;
    Vector2 titlePosition = Vector2(18, 45);
    Vector2 titleSize = Vector2(30, 10);
    if (_scoreImage != null) {
      Sprite sprite = Sprite(_scoreImage!);
      sprite.render(
        canvas,
        position: Vector2(
            _toAbsoluteX(titlePosition.x), _toAbsoluteY(titlePosition.y)),
        size: Vector2(_toAbsoluteX(titleSize.x), _toAbsoluteY(titleSize.y)),
      );
    }

    Vector2 numberPosition = Vector2(
        titlePosition.x + titleSize.x * 1.2, titlePosition.y + titleSize.y / 5);
    Vector2 numberSize = Vector2(titleSize.x / 10 * 2, titleSize.y / 5 * 4);
    Vector2 numberGap = Vector2(numberSize.x / 4 * 5, numberSize.y / 4 * 5);
    // Draw score
    int currentScore = _snakeGame.currentScore;
    if (currentScore >= 10000) {
      // Draw number inf
      if (_numberInfImage != null) {
        Sprite sprite = Sprite(_numberInfImage!);
        sprite.render(
          canvas,
          position: Vector2(
              _toAbsoluteX(numberPosition.x), _toAbsoluteY(numberPosition.y)),
          size: Vector2(
              _toAbsoluteX(numberSize.x * 2), _toAbsoluteY(numberSize.y)),
        );
      }
    }
    else if (currentScore >= 1000) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 1000]);
      sprite.render(
        canvas,
        position: Vector2(
            _toAbsoluteX(numberPosition.x), _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 1000 ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x * 2),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x * 3),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
    }
    else if (currentScore >= 100) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x * 2),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
    }
    else if (currentScore >= 10) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(
            _toAbsoluteX(numberPosition.x), _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(numberPosition.x + numberGap.x),
            _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
    }
    else if (currentScore >= 0) {
      Sprite sprite = Sprite(_numberImages[currentScore]);
      sprite.render(
        canvas,
        position: Vector2(
            _toAbsoluteX(numberPosition.x), _toAbsoluteY(numberPosition.y)),
        size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
      );
    }
    else {
      if (_numberUnknownImage != null) {
        Sprite sprite = Sprite(_numberUnknownImage!);
        sprite.render(
          canvas,
          position: Vector2(
              _toAbsoluteX(numberPosition.x), _toAbsoluteY(numberPosition.y)),
          size: Vector2(_toAbsoluteX(numberSize.x), _toAbsoluteY(numberSize.y)),
        );
      }
    }

    _buttons[GameState.gameOver]!.forEach(
            (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize));
  }


  void _drawAnimation(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if (_screenSize == null) {
      return;
    }

    final playingAnimation = _playingAnimation;
    if (playingAnimation == null) {
      return;
    }

    playingAnimation.drawOnCanvas(canvas, screenSize: _screenSize);
  }

  void _setGameOver() {

    _playingAnimation = _animations[_gameState]!["gameOver"];

       }

  void _setStartGame() {
    _snakeGame.reset();

    int imageId;
    do {
      imageId = Random().nextInt(5);
    } while (!enabledFood[imageId]);
  }


  void setSnakeForwardTime(double snakeForwardTime) {
    _snakeForwardTime = snakeForwardTime;
  }

  void setEnabledFood(List<bool> theEnabledFood) {
    enabledFood = theEnabledFood;
  }
}
