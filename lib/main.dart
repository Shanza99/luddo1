import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(LudoApp());
}

class LudoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Dice Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LudoGamePage(),
    );
  }
}

class LudoGamePage extends StatefulWidget {
  @override
  _LudoGamePageState createState() => _LudoGamePageState();
}

class _LudoGamePageState extends State<LudoGamePage>
    with SingleTickerProviderStateMixin {
  int currentPlayer = 0;
  List<int> scores = [0, 0, 0, 0];
  int rounds = 2;
  int currentRound = 0;
  int diceValue = 1;
  late AnimationController _diceAnimationController;
  late Animation<double> _diceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the dice animation
    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _diceAnimation = CurvedAnimation(
      parent: _diceAnimationController,
      curve: Curves.elasticInOut,
    );

    _diceAnimationController.addListener(() {
      setState(() {}); // Rebuild during animation to update dice rotation
    });
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    super.dispose();
  }

  void rollDice() {
    if (currentRound < rounds) {
      _diceAnimationController.forward(from: 0); // Start dice rolling animation
      setState(() {
        diceValue = Random().nextInt(6) + 1;
        scores[currentPlayer] += diceValue;
      });

      // Move to the next player
      currentPlayer = (currentPlayer + 1) % 4;
      if (currentPlayer == 0) {
        currentRound++;
      }
    } else {
      // Game over, find the winner
      _showWinner();
    }
  }

  void _showWinner() {
    int winner = scores.indexWhere((score) => score == scores.reduce(max));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Player ${winner + 1} is the winner with ${scores[winner]} points!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      currentPlayer = 0;
      scores = [0, 0, 0, 0];
      currentRound = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ludo Dice Game'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Dice animation
            Transform.rotate(
              angle: _diceAnimation.value * 2 * pi,
              child: Image.asset(
                'assets/dice$diceValue.png',
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            // Players and their scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerButton(0),
                _buildPlayerButton(1),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerButton(2),
                _buildPlayerButton(3),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: rollDice,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), backgroundColor: const Color.fromARGB(255, 217, 208, 234),
              ),
              child: Text(
                'Roll Dice',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerButton(int playerIndex) {
    bool isActive = currentPlayer == playerIndex;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isActive ? Colors.orangeAccent : Colors.black12,
            spreadRadius: 4,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Player ${playerIndex + 1}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Score: ${scores[playerIndex]}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
