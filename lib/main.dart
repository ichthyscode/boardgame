import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int boardSize = 30;
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

    ShakeDetector.autoStart(
      onPhoneShake: () {
        blinkWhiteCells();
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _movementTimer?.cancel();
    super.dispose();
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
                    width: 20,
                    height: 20,
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
                            fontSize: 10),
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
        blinkWhiteCells();
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

  void move(String keyLabel) {
    setState(() {
      switch (keyLabel) {
        case 'Arrow Up':
          if (userRow > 0) userRow--;
          break;
        case 'Arrow Down':
          if (userRow < boardSize - 1) userRow++;
          break;
        case 'Arrow Left':
          if (userCol > 0) userCol--;
          break;
        case 'Arrow Right':
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

  void blinkWhiteCells() {
    setState(() {
      _blinkGreen = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _blinkGreen = false;
        highlightedCells.clear();
      });
    });
  }

  void changeBoardSize(int change) {
    setState(() {
      boardSize += change;
      if (boardSize < 5) boardSize = 5;
      if (boardSize > 50) boardSize = 50;
      userRow = userRow.clamp(0, boardSize - 1);
      userCol = userCol.clamp(0, boardSize - 1);
      highlightedCells.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${boardSize}x$boardSize Grid Movement')),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          handleKeyboard(event);
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: buildBoard(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => changeBoardSize(-1),
                  child: const Text('Decrease Size'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => changeBoardSize(1),
                  child: const Text('Increase Size'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}