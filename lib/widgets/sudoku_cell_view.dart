import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class SudokuCellView extends StatelessWidget {
  final int row;
  final int col;

  const SudokuCellView({super.key, required this.row, required this.col});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final cell = gameState.grid?.getCell(row, col);
        if (cell == null) return const SizedBox();

        final isSelected =
            gameState.selectedRow == row && gameState.selectedCol == col;
        final isFixed = cell.isFixed;
        final hasValue = cell.value != null;

        bool isValid = true;
        if (hasValue && gameState.grid != null) {
          // Check if setting the current value at this position is a valid move.
          // Note: isValidMove checks if the value exists ELSEWHERE in row/col/box.
          isValid = gameState.grid!.isValidMove(row, col, cell.value!);
        }

        // Visual properties
        Color bgColor = Colors.white;
        if (isSelected) {
          bgColor = Colors.blue.withValues(alpha: 0.3);
        } else if (!hasValue &&
            cell.candidates.length == 1 &&
            gameState.showHighlights) {
          bgColor = Colors.lightGreen.withValues(alpha: 0.3);
        } else if (isFixed) {
          bgColor = Colors.grey.withValues(alpha: 0.1);
        }

        return GestureDetector(
          onTap: () {
            gameState.selectCell(row, col);
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: hasValue
                  ? Text(
                      cell.value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: isFixed
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !isValid
                            ? Colors.red
                            : (isFixed ? Colors.black : Colors.blueAccent),
                      ),
                    )
                  : (gameState.showCandidates
                        ? _buildNotes(cell.candidates)
                        : const SizedBox()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotes(List<int> candidates) {
    if (candidates.isEmpty) return const SizedBox();
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        final number = index + 1;
        return Center(
          child: Text(
            candidates.contains(number) ? number.toString() : '',
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        );
      }),
    );
  }
}
