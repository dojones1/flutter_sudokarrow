import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/providers/game_state.dart';
import 'package:flutter_sudokarrow/widgets/number_pad.dart';

void main() {
  late GameState gameState;

  setUp(() {
    gameState = GameState();
  });

  Widget createSubject() {
    return ChangeNotifierProvider<GameState>.value(
      value: gameState,
      child: const MaterialApp(home: Scaffold(body: NumberPad())),
    );
  }

  testWidgets('should render toggle button, clear button, and number buttons', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    // Check toggle button
    expect(find.text('Notes: OFF'), findsOneWidget);
    expect(find.byIcon(Icons.edit_off), findsOneWidget);

    // Check clear button
    expect(find.text('Clear'), findsOneWidget);
    expect(find.byIcon(Icons.backspace), findsOneWidget);

    // Check number buttons 1-9
    for (int i = 1; i <= 9; i++) {
      expect(find.text(i.toString()), findsOneWidget);
    }
  });

  testWidgets('should toggle input mode when toggle button is tapped', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject());

    // Initially notes off
    expect(gameState.inputMode, InputMode.value);
    expect(find.text('Notes: OFF'), findsOneWidget);
    expect(find.byIcon(Icons.edit_off), findsOneWidget);

    // Tap toggle
    await tester.tap(find.text('Notes: OFF'));
    await tester.pump();

    expect(gameState.inputMode, InputMode.notes);
    expect(find.text('Notes: ON'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);

    // Check button color - TODO: Implement color check if needed

    // Tap again
    await tester.tap(find.text('Notes: ON'));
    await tester.pump();

    expect(gameState.inputMode, InputMode.value);
    expect(find.text('Notes: OFF'), findsOneWidget);
    expect(find.byIcon(Icons.edit_off), findsOneWidget);
  });

  testWidgets('should call clearCell when clear button is tapped', (
    tester,
  ) async {
    final grid = SudokuGrid.empty();
    grid.setCell(0, 0, 5);
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );
    gameState.selectCell(0, 0);

    await tester.pumpWidget(createSubject());

    expect(gameState.grid!.getCell(0, 0).value, 5);

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(gameState.grid!.getCell(0, 0).value, null);
  });

  testWidgets(
    'should call numberInput when number button is tapped in value mode',
    (tester) async {
      final grid = SudokuGrid.empty();
      gameState.startGame(
        Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
      );
      gameState.selectCell(0, 0);

      await tester.pumpWidget(createSubject());

      expect(gameState.grid!.getCell(0, 0).value, null);

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(gameState.grid!.getCell(0, 0).value, 5);
    },
  );

  testWidgets(
    'should call numberInput when number button is tapped in notes mode',
    (tester) async {
      final grid = SudokuGrid.empty();
      gameState.startGame(
        Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
      );
      gameState.selectCell(0, 0);
      gameState.toggleInputMode(); // Notes mode

      await tester.pumpWidget(createSubject());

      expect(gameState.grid!.getCell(0, 0).candidates, isEmpty);

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(gameState.grid!.getCell(0, 0).candidates, contains(3));
    },
  );
}
