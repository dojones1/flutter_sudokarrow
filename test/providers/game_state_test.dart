import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/providers/game_state.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';

void main() {
  group('GameState', () {
    late GameState gameState;
    late Puzzle testPuzzle;

    setUp(() {
      gameState = GameState();
      testPuzzle = Puzzle(
        id: 'test',
        title: 'Test Puzzle',
        description: 'A test puzzle',
        grid: SudokuGrid.empty(),
      );
      gameState.startGame(testPuzzle);
    });

    test('initial state should have no moves', () {
      expect(gameState.canUndo, isFalse);
    });

    test('after placing a value, should be able to undo', () {
      gameState.selectCell(0, 0);
      gameState.numberInput(5);
      expect(gameState.canUndo, isTrue);
    });

    test('undo should revert the last move', () {
      gameState.selectCell(0, 0);
      gameState.numberInput(5);
      expect(gameState.grid!.getCell(0, 0).value, 5);
      gameState.undo();
      expect(gameState.grid!.getCell(0, 0).value, isNull);
      expect(gameState.canUndo, isFalse);
    });

    test('toggleCandidatesVisibility should toggle showCandidates', () {
      expect(gameState.showCandidates, isTrue);
      gameState.toggleCandidatesVisibility();
      expect(gameState.showCandidates, isFalse);
      gameState.toggleCandidatesVisibility();
      expect(gameState.showCandidates, isTrue);
    });

    test('toggleHighlights should toggle showHighlights', () {
      expect(gameState.showHighlights, isTrue);
      gameState.toggleHighlights();
      expect(gameState.showHighlights, isFalse);
      gameState.toggleHighlights();
      expect(gameState.showHighlights, isTrue);
    });

    test('startGame should reset moves', () {
      gameState.selectCell(0, 0);
      gameState.numberInput(5);
      expect(gameState.canUndo, isTrue);
      gameState.startGame(testPuzzle);
      expect(gameState.canUndo, isFalse);
    });
  });
}
