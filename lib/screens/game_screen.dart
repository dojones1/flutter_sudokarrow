import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/sudoku_grid_view.dart';
import '../widgets/number_pad.dart';
import '../services/file_storage_service.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _saveGame(BuildContext context, GameState gameState) async {
    final service = FileStorageService();
    if (gameState.currentPuzzle != null) {
      await service.savePuzzle(gameState.currentPuzzle!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Puzzle Saved!')));
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
              } else {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lightbulb),
                      onPressed: () {
                        gameState.getHint();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              gameState.hintedValue != null
                                  ? 'Hint: Try ${gameState.hintedValue} at row ${gameState.hintedRow! + 1}, col ${gameState.hintedCol! + 1} because it doesn\'t conflict with existing numbers in the same row, column, or 3x3 box.'
                                  : 'No hint available',
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.note_add),
                      onPressed: () {
                        gameState.autoPopulateNotes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notes auto-populated!'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final keyLabel = event.logicalKey.keyLabel;
            final number = int.tryParse(keyLabel);
            if (number != null && number >= 1 && number <= 9) {
              final gameState = Provider.of<GameState>(context, listen: false);
              gameState.numberInput(number);
            }
          }
        },
        child: Center(
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
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
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
      ),
    );
  }
}
