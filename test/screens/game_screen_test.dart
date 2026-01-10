import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/providers/game_state.dart';
import 'package:flutter_sudokarrow/screens/game_screen.dart';
import 'package:flutter_sudokarrow/widgets/sudoku_grid_view.dart';
import 'package:flutter_sudokarrow/widgets/number_pad.dart';

void main() {
  late GameState gameState;

  setUp(() {
    gameState = GameState();
  });

  Widget createSubject() {
    return ChangeNotifierProvider<GameState>.value(
      value: gameState,
      child: const MaterialApp(home: GameScreen()),
    );
  }

  testWidgets('should display default title when no puzzle', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.text('Sudoku'), findsOneWidget);
  });

  testWidgets('should display puzzle title', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'Test Puzzle', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    expect(find.text('Test Puzzle'), findsOneWidget);
  });

  testWidgets('should show author mode actions when in author mode', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
      authorMode: true,
    );

    await tester.pumpWidget(createSubject());

    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.text('Author Mode'), findsOneWidget);
  });

  testWidgets('should show play mode actions when not in author mode', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.byIcon(Icons.note_add), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.highlight), findsOneWidget);
  });

  testWidgets('should show solved text when puzzle is solved', (tester) async {
    // Create a valid solved Sudoku grid
    final solvedValues = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [4, 5, 6, 7, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 2, 3, 4, 5, 6],
      [2, 3, 4, 5, 6, 7, 8, 9, 1],
      [5, 6, 7, 8, 9, 1, 2, 3, 4],
      [8, 9, 1, 2, 3, 4, 5, 6, 7],
      [3, 4, 5, 6, 7, 8, 9, 1, 2],
      [6, 7, 8, 9, 1, 2, 3, 4, 5],
      [9, 1, 2, 3, 4, 5, 6, 7, 8],
    ];
    final grid = SudokuGrid.fromFixedValues(solvedValues);
    gameState.startGame(
      Puzzle(
        id: '1',
        title: 'Solved Puzzle',
        description: 'Test solved puzzle',
        grid: grid,
      ),
    );

    await tester.pumpWidget(createSubject());

    expect(find.text('Solved! 🎉'), findsOneWidget);
  });

  testWidgets('should not show solved text when puzzle is not solved', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(
        id: '1',
        title: 'Unsolved Puzzle',
        description: 'Test unsolved puzzle',
        grid: grid,
      ),
    );

    await tester.pumpWidget(createSubject());

    expect(find.text('Solved! 🎉'), findsNothing);
  });

  testWidgets('should render SudokuGridView and NumberPad', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    expect(find.byType(SudokuGridView), findsOneWidget);
    expect(find.byType(NumberPad), findsOneWidget);
  });

  testWidgets('should handle keyboard input for numbers', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );
    gameState.selectCell(0, 0);

    await tester.pumpWidget(createSubject());

    // Simulate key press
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump();

    expect(gameState.grid!.getCell(0, 0).value, 1);
  });
}
