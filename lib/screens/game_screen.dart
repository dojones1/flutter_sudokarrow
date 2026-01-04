import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/sudoku_grid_view.dart';
import '../widgets/number_pad.dart';
import '../services/file_storage_service.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  void _saveGame(BuildContext context, GameState gameState) async {
      final service = FileStorageService();
      if (gameState.currentPuzzle != null) {
          await service.savePuzzle(gameState.currentPuzzle!);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Puzzle Saved!')),
          );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GameState>(
          builder: (context, gameState, child) {
            return Text(gameState.currentPuzzle?.title ?? 'Sudoku');
          },
        ),
        actions: [
          Consumer<GameState>(
            builder: (context, gameState, child) {
              if (gameState.authorMode) {
                return Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () => _saveGame(context, gameState),
                    ),
                    const Chip(
                      label: Text('Author Mode'),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SudokuGridView(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: NumberPad(),
              ),
              Consumer<GameState>(
                builder: (context, gameState, child) {
                  if (gameState.isSolved && !gameState.authorMode) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Solved! 🎉',
                        style: TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
