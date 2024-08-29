import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const int boardSize = 30;
  int userRow = 0;
  int userCol = 0;
  final FocusNode _focusNode = FocusNode();
  Set<String> highlightedCells = {};

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
                bool isHighlighted = highlightedCells.contains('$row,$col');
                return GestureDetector(
                  onTap: () => handleTap(row, col),
                  child: Container(
                    width: 20,
                    height: 20,
                    color: isUserBlock 
                      ? Colors.green 
                      : isHighlighted 
                        ? Colors.purple 
                        : (row + col) % 2 == 0 ? Colors.white : Colors.black,
                    child: Center(
                      child: Text(
                        isUserBlock ? 'U' : '',
                        style: TextStyle(color: isUserBlock ? Colors.white : Colors.black, fontSize: 10),
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
      setState(() {
        switch (event.logicalKey.keyLabel) {
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
  }

  void updateHighlightedCells() {
    List<String> surroundingCells = [
      '${userRow-1},${userCol}', '${userRow+1},${userCol}',
      '${userRow},${userCol-1}', '${userRow},${userCol+1}'
    ];
    
    for (String cell in surroundingCells) {
      if (highlightedCells.contains(cell)) {
        highlightedCells.remove(cell);
      } else {
        highlightedCells.add(cell);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('30x30 Grid Movement')),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          handleKeyboard(event);
        },
        child: Center(
          child: buildBoard(),
        ),
      ),
    );
  }
}