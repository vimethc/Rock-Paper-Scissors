import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:rock_paper_scissors/onboarding_screen.dart';
import 'package:rock_paper_scissors/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  String? playerChoice;
  String? computerChoice;
  String result = '';
  int playerScore = 0;
  int computerScore = 0;
  int gamesToWin = 3; // Best of 5 games
  final random = Random();
  final audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, String>> gameHistory = [];

  final Map<String, IconData> choiceIcons = {
    'rock': Icons.rocket_launch,
    'paper': Icons.description,
    'scissors': Icons.content_cut,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound(String sound) async {
    await audioPlayer.play(AssetSource('sounds/$sound.mp3'));
  }

  void resetGame() {
    setState(() {
      playerScore = 0;
      computerScore = 0;
      result = '';
      playerChoice = null;
      computerChoice = null;
      gameHistory.clear();
    });
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Game?'),
          content: const Text('Are you sure you want to reset the game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void playGame(String choice) async {
    setState(() {
      playerChoice = choice;
      computerChoice = ['rock', 'paper', 'scissors'][random.nextInt(3)];
    });

    await playSound('click');
    _controller.forward(from: 0.0);

    setState(() {
      result = determineWinner(playerChoice!, computerChoice!);
      gameHistory.insert(0, {
        'player': playerChoice!,
        'computer': computerChoice!,
        'result': result,
      });
      if (gameHistory.length > 5) {
        gameHistory.removeLast();
      }
    });

    if (result == 'You Win!') {
      await playSound('win');
    } else if (result == 'Computer Wins!') {
      await playSound('lose');
    } else {
      await playSound('draw');
    }

    if (playerScore >= gamesToWin || computerScore >= gamesToWin) {
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            playerScore > computerScore
                ? 'Congratulations! You won the game!'
                : 'Computer won the game!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  String determineWinner(String player, String computer) {
    if (player == computer) {
      return 'Draw!';
    }

    if ((player == 'rock' && computer == 'scissors') ||
        (player == 'paper' && computer == 'rock') ||
        (player == 'scissors' && computer == 'paper')) {
      playerScore++;
      return 'You Win!';
    } else {
      computerScore++;
      return 'Computer Wins!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: showResetDialog,
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Player: $playerScore',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Computer: $computerScore',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Progress to Win
            LinearProgressIndicator(
              value: (playerScore + computerScore) / (gamesToWin * 2),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                playerScore > computerScore ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            
            // Choices Display with Animation
            ScaleTransition(
              scale: _animation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            playerChoice != null ? choiceIcons[playerChoice] : Icons.question_mark,
                            size: 60,
                          ),
                          const SizedBox(height: 8),
                          const Text('Your Choice'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            computerChoice != null ? choiceIcons[computerChoice] : Icons.question_mark,
                            size: 60,
                          ),
                          const SizedBox(height: 8),
                          const Text('Computer'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Result Display
            Text(
              result,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: result == 'You Win!' ? Colors.green :
                       result == 'Computer Wins!' ? Colors.red :
                       Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            
            // Choice Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => playGame('rock'),
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Rock'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => playGame('paper'),
                      icon: const Icon(Icons.description),
                      label: const Text('Paper'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => playGame('scissors'),
                      icon: const Icon(Icons.content_cut),
                      label: const Text('Scissors'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Game History
            Expanded(
              child: ListView.builder(
                itemCount: gameHistory.length,
                itemBuilder: (context, index) {
                  final game = gameHistory[index];
                  return ListTile(
                    leading: Icon(choiceIcons[game['player']]),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(choiceIcons[game['player']]),
                        const SizedBox(width: 8),
                        const Text('vs'),
                        const SizedBox(width: 8),
                        Icon(choiceIcons[game['computer']]),
                      ],
                    ),
                    trailing: Text(
                      game['result']!,
                      style: TextStyle(
                        color: game['result'] == 'You Win!' ? Colors.green :
                               game['result'] == 'Computer Wins!' ? Colors.red :
                               Colors.orange,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
