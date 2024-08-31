import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shake/shake.dart';

void main() => runApp(const ChessBoardApp());

class ChessBoardApp extends StatelessWidget {
  const ChessBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  ChessBoardScreenState createState() => ChessBoardScreenState();
}

class ChessBoardScreenState extends State<ChessBoardScreen> {
  late int boardSize;
  late double cellSize;
  int userRow = 0;
  int userCol = 0;
  final FocusNode _focusNode = FocusNode();
  Set<String> highlightedCells = {};
  Timer? _movementTimer;
  bool _blinkGreen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    if (!kIsWeb) {
      ShakeDetector.autoStart(
        onPhoneShake: () {
          clearEverything();
        },
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _movementTimer?.cancel();
    super.dispose();
  }

  void calculateBoardSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;

    const desiredCellSize = 30.0;
    const minBoardSize = 10;
    const maxBoardSize = 50;

    boardSize = (shortestSide / desiredCellSize).floor();
    boardSize = boardSize.clamp(minBoardSize, maxBoardSize);

    cellSize = shortestSide / boardSize;

    userRow = userRow.clamp(0, boardSize - 1);
    userCol = userCol.clamp(0, boardSize - 1);
  }

  Widget buildBoard() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(boardSize, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(boardSize, (col) {
                bool isUserBlock = row == userRow && col == userCol;
                bool isWhiteCell = (row + col) % 2 == 0;
                bool isHighlighted = highlightedCells.contains('$row,$col');
                return GestureDetector(
                  onTap: () => handleTap(row, col),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    color: isUserBlock
                        ? Colors.green
                        : _blinkGreen && isWhiteCell
                        ? Colors.green
                        : isHighlighted
                        ? Colors.purple
                        : isWhiteCell
                        ? Colors.white
                        : Colors.black,
                    child: Center(
                      child: Text(
                        isUserBlock ? 'U' : '',
                        style: TextStyle(
                            color: isUserBlock ? Colors.white : Colors.black,
                            fontSize: cellSize / 2),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  void handleTap(int row, int col) {
    if ((row == userRow && (col == userCol - 1 || col == userCol + 1)) ||
        (col == userCol && (row == userRow - 1 || row == userRow + 1))) {
      setState(() {
        userRow = row;
        userCol = col;
        updateHighlightedCells();
      });
    }
  }

  void handleKeyboard(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        clearEverything();
      } else {
        startMovement(event.logicalKey.keyLabel);
      }
    } else if (event is KeyUpEvent) {
      stopMovement();
    }
  }

  void startMovement(String keyLabel) {
    move(keyLabel);
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      move(keyLabel);
    });
  }

  void stopMovement() {
    _movementTimer?.cancel();
  }

  void move(String direction) {
    setState(() {
      switch (direction) {
        case 'Arrow Up':
        case 'Up':
          if (userRow > 0) userRow--;
          break;
        case 'Arrow Down':
        case 'Down':
          if (userRow < boardSize - 1) userRow++;
          break;
        case 'Arrow Left':
        case 'Left':
          if (userCol > 0) userCol--;
          break;
        case 'Arrow Right':
        case 'Right':
          if (userCol < boardSize - 1) userCol++;
          break;
      }
      updateHighlightedCells();
    });
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
    setState(() {
      _blinkGreen = true;
      highlightedCells.clear();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _blinkGreen = false;
      });
    });
  }

  void handleSwipe(DragUpdateDetails details) {
    const int sensitivity = 5;
    if (details.delta.dx.abs() > sensitivity || details.delta.dy.abs() > sensitivity) {
      if (details.delta.dx.abs() > details.delta.dy.abs()) {
        // Horizontal swipe
        if (details.delta.dx > 0) {
          move('Right');
        } else {
          move('Left');
        }
      } else {
        // Vertical swipe
        if (details.delta.dy > 0) {
          move('Down');
        } else {
          move('Up');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateBoardSize(context);
    return Scaffold(
      appBar: AppBar(title: Text('${boardSize}x$boardSize Grid Movement')),
      body: Column(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: (KeyEvent event) {
                handleKeyboard(event);
              },
              child: GestureDetector(
                onPanUpdate: (details) {
                  handleSwipe(details);
                },
                child: Center(
                  child: buildBoard(),
                ),
              ),
            ),
          ),
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: clearEverything,
                child: const Text('Clear Everything'),
              ),
            ),
        ],
      ),
    );
  }
}