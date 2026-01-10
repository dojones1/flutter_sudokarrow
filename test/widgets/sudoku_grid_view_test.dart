import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/providers/game_state.dart';
import 'package:flutter_sudokarrow/widgets/sudoku_grid_view.dart';
import 'package:flutter_sudokarrow/widgets/sudoku_cell_view.dart';

void main() {
  late GameState gameState;

  setUp(() {
    gameState = GameState();
  });

  Widget createSubject() {
    return ChangeNotifierProvider<GameState>.value(
      value: gameState,
      child: const MaterialApp(home: Scaffold(body: SudokuGridView())),
    );
  }

  testWidgets('should show CircularProgressIndicator when grid is null', (
    tester,
  ) async {
    // gameState.grid is null by default

    await tester.pumpWidget(createSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should render grid when grid is not null', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    // Should not show CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Should render AspectRatio
    expect(find.byType(AspectRatio), findsOneWidget);

    // Should render Column
    expect(find.byType(Column), findsOneWidget);

    // Should render 9 Rows
    expect(find.byType(Row), findsNWidgets(9));

    // Should render 81 SudokuCellView
    expect(find.byType(SudokuCellView), findsNWidgets(81));
  });
}
