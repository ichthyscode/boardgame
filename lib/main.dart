import 'package:flutter/material.dart';

void main() => runApp(ChessBoardApp());

class ChessBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  // Define the size of the board
  static const int boardSize = 8;
  // Define the initial position of the user block
  int userRow = 0;
  int userCol = 0;

  // Method to build the chessboard
  Widget buildBoard() {
    return Column(
      children: List.generate(boardSize, (row) {
        return Row(
          children: List.generate(boardSize, (col) {
            bool isUserBlock = row == userRow && col == userCol;
            return Container(
              width: 40,
              height: 40,
              color: isUserBlock ? Colors.green : (row + col) % 2 == 0 ? Colors.white : Colors.black,
              child: Center(
                child: Text(
                  isUserBlock ? 'U' : '',
                  style: TextStyle(color: isUserBlock ? Colors.white : Colors.black),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // Method to handle user movement
  void moveUser(String direction) {
    setState(() {
      switch (direction) {
        case 'up':
          if (userRow > 0) userRow--;
          break;
        case 'down':
          if (userRow < boardSize - 1) userRow++;
          break;
        case 'left':
          if (userCol > 0) userCol--;
          break;
        case 'right':
          if (userCol < boardSize - 1) userCol++;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chessboard Movement')),
      body: Column(
        children: [
          buildBoard(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => moveUser('up'), child: Text('Up')),
              ElevatedButton(onPressed: () => moveUser('down'), child: Text('Down')),
              ElevatedButton(onPressed: () => moveUser('left'), child: Text('Left')),
              ElevatedButton(onPressed: () => moveUser('right'), child: Text('Right')),
            ],
          ),
        ],
      ),
    );
  }
}