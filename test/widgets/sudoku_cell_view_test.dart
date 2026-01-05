import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/providers/game_state.dart';
import 'package:flutter_sudokarrow/widgets/sudoku_cell_view.dart';

void main() {
  late GameState gameState;

  setUp(() {
    gameState = GameState();
  });

  Widget createSubject({required int row, required int col}) {
    return ChangeNotifierProvider<GameState>.value(
      value: gameState,
      child: MaterialApp(
        home: Scaffold(
          body: SudokuCellView(row: row, col: col),
        ),
      ),
    );
  }

  testWidgets('should render empty cell', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject(row: 0, col: 0));

    expect(find.text('0'), findsNothing);
    expect(find.byType(Text), findsNothing); // No text means empty
    expect(find.byType(GridView), findsNothing); // No notes
  });

  testWidgets('should display value when cell has value', (tester) async {
    final grid = SudokuGrid.empty();
    grid.setCell(0, 0, 5);
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject(row: 0, col: 0));

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('should display notes when cell has notes', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    // Select cell and add notes
    gameState.selectCell(0, 0);
    gameState.toggleInputMode(); // Note mode
    gameState.numberInput(1);
    gameState.numberInput(9);

    await tester.pumpWidget(createSubject(row: 0, col: 0));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('should style fixed cells bold and black', (tester) async {
    final grid = SudokuGrid.fromFixedValues([
      [5, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ]);
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject(row: 0, col: 0));

    final text = tester.widget<Text>(find.text('5'));
    expect(text.style?.fontWeight, FontWeight.bold);
    expect(text.style?.color, Colors.black);

    // Verify background color logic requires checking Container decoration
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNotNull); // Should be grey tint
  });

  testWidgets('should style mutable cells normal and blue', (tester) async {
    final grid = SudokuGrid.empty();
    grid.setCell(0, 0, 5); // Mutable
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject(row: 0, col: 0));

    final text = tester.widget<Text>(find.text('5'));
    expect(text.style?.fontWeight, FontWeight.normal);
    expect(text.style?.color, Colors.blueAccent);
  });

  testWidgets('should style invalid cells red', (tester) async {
    // Setup a grid with a conflict
    final grid = SudokuGrid.empty();
    grid.setCell(0, 0, 5);
    grid.setCell(0, 1, 5); // Conflict in row
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(
      createSubject(row: 0, col: 1),
    ); // Check the second 5

    final text = tester.widget<Text>(find.text('5'));
    expect(text.style?.color, Colors.red);
  });

  testWidgets('should style selected cell', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    gameState.selectCell(2, 2);

    await tester.pumpWidget(createSubject(row: 2, col: 2));

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    // Blue tint for selection
    expect(decoration.color, equals(Colors.blue.withValues(alpha: 0.3)));
  });

  testWidgets('tapping cell should select it', (tester) async {
    final grid = SudokuGrid.empty();
    gameState.startGame(
      Puzzle(id: '1', title: 'T', description: 'D', grid: grid),
    );

    await tester.pumpWidget(createSubject(row: 1, col: 1));

    expect(gameState.selectedRow, isNull);
    expect(gameState.selectedCol, isNull);

    await tester.tap(find.byType(GestureDetector));

    expect(gameState.selectedRow, 1);
    expect(gameState.selectedCol, 1);
  });
}
