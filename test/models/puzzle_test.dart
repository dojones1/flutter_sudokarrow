import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';

void main() {
  group('Puzzle', () {
    test('constructor should initialize fields correctly', () {
      final grid = SudokuGrid.empty();
      final puzzle = Puzzle(
        id: 'test-id',
        title: 'Test Puzzle',
        description: 'A test puzzle',
        grid: grid,
      );

      expect(puzzle.id, 'test-id');
      expect(puzzle.title, 'Test Puzzle');
      expect(puzzle.description, 'A test puzzle');
      expect(puzzle.grid, grid);
    });

    test('serialization round trip should preserve puzzle data', () {
      final grid = SudokuGrid.empty();
      // Modify grid slightly to ensure deep structure is preserved
      grid.setCell(0, 0, 5);

      final puzzle = Puzzle(
        id: 'puz-123',
        title: 'Hard Puzzle',
        description: 'Very hard',
        grid: grid,
      );

      final json = puzzle.toJson();
      final revivedPuzzle = Puzzle.fromJson(json);

      expect(revivedPuzzle.id, 'puz-123');
      expect(revivedPuzzle.title, 'Hard Puzzle');
      expect(revivedPuzzle.description, 'Very hard');
      // Check specific grid value to ensure it was serialized correctly
      expect(revivedPuzzle.grid.getCell(0, 0).value, 5);
      // Check dimensions
      expect(revivedPuzzle.grid.rows.length, 9);
    });
  });
}
