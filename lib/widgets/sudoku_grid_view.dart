import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import 'sudoku_cell_view.dart';

class SudokuGridView extends StatelessWidget {
  const SudokuGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.grid == null) return const Center(child: CircularProgressIndicator());

        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            child: Column(
              children: List.generate(9, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(9, (col) {
                      // Determine border thickness for 3x3 boxes
                      final borderRight = (col + 1) % 3 == 0 && col != 8;
                      final borderBottom = (row + 1) % 3 == 0 && row != 8;

                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: borderRight ? Colors.black : Colors.grey.withOpacity(0.5),
                                width: borderRight ? 2.0 : 0.5,
                              ),
                              bottom: BorderSide(
                                color: borderBottom ? Colors.black : Colors.grey.withOpacity(0.5),
                                width: borderBottom ? 2.0 : 0.5,
                              ),
                            ),
                          ),
                          child: SudokuCellView(row: row, col: col),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
