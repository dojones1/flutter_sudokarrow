import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            // Control Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: gameState.toggleInputMode,
                  icon: Icon(
                    gameState.inputMode == InputMode.notes
                        ? Icons.edit
                        : Icons.edit_off,
                  ),
                  label: Text(
                    gameState.inputMode == InputMode.notes
                        ? 'Notes: ON'
                        : 'Notes: OFF',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gameState.inputMode == InputMode.notes
                        ? Colors.amber
                        : null,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: gameState.clearCell,
                  icon: const Icon(Icons.backspace),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // numbers 1-9
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: List.generate(9, (index) {
                final number = index + 1;
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => gameState.numberInput(number),
                    child: Text(
                      number.toString(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
