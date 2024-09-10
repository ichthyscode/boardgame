import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: ChessBoardGame(),
    ),
  );
}

class ChessBoardGame extends FlameGame with TapDetector, PanDetector {
  static const int boardSize = 30;
  late final PositionComponent boardComponent;
  int userRow = 0;
  int userCol = 0;
  Set<String> highlightedCells = {};
  bool _blinkGreen = false;
  late final Timer blinkTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    boardComponent = PositionComponent();
    add(boardComponent);
    createBoard();

    blinkTimer = Timer(0.5, onTick: () {
      _blinkGreen = !_blinkGreen;
    }, repeat: true);
  }

  void createBoard() {
    double cellSize = size.x / boardSize;
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        bool isWhiteCell = (row + col) % 2 == 0;
        RectangleComponent cell = RectangleComponent(
          position: Vector2(col * cellSize, row * cellSize),
          size: Vector2.all(cellSize),
          paint: Paint()..color = isWhiteCell ? Colors.white : Colors.black,
        );
        boardComponent.add(cell);
      }
    }
    updateUserPosition();
  }

  void updateUserPosition() {
    boardComponent.children.whereType<RectangleComponent>().forEach((cell) {
      cell.removeFromParent();
    });
    createBoard();

    double cellSize = size.x / boardSize;
    RectangleComponent userCell = RectangleComponent(
      position: Vector2(userCol * cellSize, userRow * cellSize),
      size: Vector2.all(cellSize),
      paint: Paint()..color = Colors.green,
    );
    boardComponent.add(userCell);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderHighlightedCells(canvas);
  }

  void renderHighlightedCells(Canvas canvas) {
    double cellSize = size.x / boardSize;
    final purplePaint = Paint()..color = Colors.purple.withOpacity(0.5);

    for (String cell in highlightedCells) {
      List<String> coords = cell.split(',');
      int row = int.parse(coords[0]);
      int col = int.parse(coords[1]);
      canvas.drawRect(
        Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
        purplePaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    blinkTimer.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    Vector2 tapPosition = info.eventPosition.global;
    double cellSize = size.x / boardSize;
    int tappedRow = (tapPosition.y / cellSize).floor();
    int tappedCol = (tapPosition.x / cellSize).floor();

    if ((tappedRow == userRow && (tappedCol == userCol - 1 || tappedCol == userCol + 1)) ||
        (tappedCol == userCol && (tappedRow == userRow - 1 || tappedRow == userRow + 1))) {
      userRow = tappedRow;
      userCol = tappedCol;
      updateHighlightedCells();
      updateUserPosition();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    const int sensitivity = 5;
    if (info.delta.global.length > sensitivity) {
      if (info.delta.global.x.abs() > info.delta.global.y.abs()) {
        // Horizontal swipe
        if (info.delta.global.x > 0) {
          move('Right');
        } else {
          move('Left');
        }
      } else {
        // Vertical swipe
        if (info.delta.global.y > 0) {
          move('Down');
        } else {
          move('Up');
        }
      }
    }
  }

  void move(String direction) {
    switch (direction) {
      case 'Up':
        if (userRow > 0) userRow--;
        break;
      case 'Down':
        if (userRow < boardSize - 1) userRow++;
        break;
      case 'Left':
        if (userCol > 0) userCol--;
        break;
      case 'Right':
        if (userCol < boardSize - 1) userCol++;
        break;
    }
    updateHighlightedCells();
    updateUserPosition();
  }

  void updateHighlightedCells() {
    List<String> surroundingCells = [
      '${userRow - 1},$userCol',
      '${userRow + 1},$userCol',
      '$userRow,${userCol - 1}',
      '$userRow,${userCol + 1}'
    ];

    for (String cell in surroundingCells) {
      if (highlightedCells.contains(cell)) {
        highlightedCells.remove(cell);
      } else {
        highlightedCells.add(cell);
      }
    }
  }

  void clearEverything() {
    _blinkGreen = true;
    highlightedCells.clear();
    blinkTimer.start();
    Future.delayed(const Duration(seconds: 1), () {
      _blinkGreen = false;
      blinkTimer.stop();
    });
  }
}