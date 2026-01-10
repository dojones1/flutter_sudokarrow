import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/models/sudoku_cell.dart';

void main() {
  group('SudokuGrid', () {
    test('empty factory should create 9x9 grid of empty cells', () {
      final grid = SudokuGrid.empty();
      expect(grid.rows.length, 9);
      for (final row in grid.rows) {
        expect(row.length, 9);
        for (final cell in row) {
          expect(cell.value, isNull);
        }
      }
    });

    test('fromFixedValues should create grid with set values', () {
      final values = List.generate(9, (_) => List.filled(9, 0));
      values[0][0] = 5;
      values[8][8] = 9;

      final grid = SudokuGrid.fromFixedValues(values);
      expect(grid.getCell(0, 0).value, 5);
      expect(grid.getCell(0, 0).isFixed, isTrue);
      expect(grid.getCell(8, 8).value, 9);
      expect(grid.getCell(8, 8).isFixed, isTrue);
      expect(grid.getCell(1, 1).value, isNull);
      expect(grid.getCell(1, 1).isFixed, isFalse);
    });

    test('constructor should throw ArgumentError for invalid dimensions', () {
      expect(() => SudokuGrid(rows: []), throwsArgumentError); // Empty rows
      expect(
        () => SudokuGrid(
          rows: List.generate(8, (_) => List.generate(9, (_) => SudokuCell())),
        ), // Only 8 rows
        throwsArgumentError,
      );
      expect(
        () => SudokuGrid(
          rows: List.generate(9, (_) => List.generate(8, (_) => SudokuCell())),
        ), // Rows valid, cols invalid
        throwsArgumentError,
      );
    });

    test('isValidMove should return true for valid placement', () {
      final grid = SudokuGrid.empty();
      // Place 1 at (0,0). Board is empty, so should be valid.
      expect(grid.isValidMove(0, 0, 1), isTrue);
    });

    test('isValidMove should return false for row conflict', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      // Try to place 5 at (0, 8) - same row
      expect(grid.isValidMove(0, 8, 5), isFalse);
    });

    test('isValidMove should return false for column conflict', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      // Try to place 5 at (8, 0) - same column
      expect(grid.isValidMove(8, 0, 5), isFalse);
    });

    test('isValidMove should return false for 3x3 box conflict', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      // Try to place 5 at (1, 1) - same box (top-left)
      expect(grid.isValidMove(1, 1, 5), isFalse);
    });

    test(
      'isValidMove should return true if checking same value at same position (no other conflicts)',
      () {
        final grid = SudokuGrid.empty();
        grid.setCell(0, 0, 5);
        // Checking if 5 is valid at (0,0) where it already is.
        // Logic: It skips the current cell in row/col/box checks, so it should be valid IF no other 5 is around.
        expect(grid.isValidMove(0, 0, 5), isTrue);
      },
    );

    test('setCell should update value', () {
      final grid = SudokuGrid.empty();
      grid.setCell(4, 4, 9);
      expect(grid.getCell(4, 4).value, 9);
    });

    test('setCell should clear value when null is passed', () {
      final grid = SudokuGrid.empty();
      grid.setCell(4, 4, 9);
      expect(grid.getCell(4, 4).value, 9);

      grid.setCell(4, 4, null);
      expect(grid.getCell(4, 4).value, isNull);
    });

    test('setCell should not modify fixed cells', () {
      final grid = SudokuGrid.empty();
      grid.getCell(2, 2).isFixed = true;
      grid.getCell(2, 2).value = 1; // Initially 1

      grid.setCell(2, 2, 2); // Try to change to 2
      expect(grid.getCell(2, 2).value, 1);
    });

    test('isSolved should return true for completely valid board', () {
      // Create a valid solved board (simplified example or constructing one)
      // Since constructing a full valid board is tedious, let's just test a small successful scenario
      // if possible, OR we can trust the logic if we fill it correctly.
      // Let's create a Helper to populate a known valid board.
      //
      // Valid Board Example:
      // 5 3 4 | 6 7 8 | 9 1 2
      // 6 7 2 | 1 9 5 | 3 4 8
      // 1 9 8 | 3 4 2 | 5 6 7
      // ------+-------+------
      // 8 5 9 | 7 6 1 | 4 2 3
      // 4 2 6 | 8 5 3 | 7 9 1
      // 7 1 3 | 9 2 4 | 8 5 6
      // ------+-------+------
      // 9 6 1 | 5 3 7 | 2 8 4
      // 2 8 7 | 4 1 9 | 6 3 5
      // 3 4 5 | 2 8 6 | 1 7 9

      final grid = SudokuGrid.empty();
      final validBoard = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          grid.rows[r][c].value = validBoard[r][c];
        }
      }

      expect(grid.isSolved(), isTrue);
    });

    test('isSolved should return false for incomplete board', () {
      final grid = SudokuGrid.empty();
      // Fill just one cell
      grid.rows[0][0].value = 5;
      expect(grid.isSolved(), isFalse);
    });

    test('serialization round trip should preserve grid state', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 1);
      grid.getCell(1, 1).isFixed = true;
      grid.getCell(1, 1).value = 2;

      final json = grid.toJson();
      final revivedGrid = SudokuGrid.fromJson(json);

      expect(revivedGrid.getCell(0, 0).value, 1);
      expect(revivedGrid.getCell(0, 0).isFixed, isFalse);

      expect(revivedGrid.getCell(1, 1).value, 2);
      expect(revivedGrid.getCell(1, 1).isFixed, isTrue);
    });

    test('getHint should return a valid hint for empty grid', () {
      final grid = SudokuGrid.empty();
      final hint = grid.getHint();
      expect(hint, isNotNull);
      expect(hint!['row'], isA<int>());
      expect(hint['col'], isA<int>());
      expect(hint['value'], isA<int>());
      expect(hint['value'], inInclusiveRange(1, 9));
      // Verify the hint is valid
      expect(
        grid.isValidMove(hint['row']!, hint['col']!, hint['value']!),
        isTrue,
      );
    });

    test('getHint should return null for solved grid', () {
      final grid = SudokuGrid.empty();
      // Populate with a solved grid
      final solvedValues = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          grid.rows[r][c].value = solvedValues[r][c];
        }
      }
      expect(grid.getHint(), isNull);
    });

    test('autoPopulateNotes should populate candidates for empty grid', () {
      final grid = SudokuGrid.empty();
      grid.autoPopulateNotes();
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = grid.getCell(r, c);
          expect(cell.candidates, containsAll([1, 2, 3, 4, 5, 6, 7, 8, 9]));
        }
      }
    });

    test('autoPopulateNotes should respect existing values', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      grid.autoPopulateNotes();
      // Cell (0,0) should have no candidates since it has value
      expect(grid.getCell(0, 0).candidates, isEmpty);
      // Other cells in row 0 should not have 5 as candidate
      for (int c = 1; c < 9; c++) {
        expect(grid.getCell(0, c).candidates, isNot(contains(5)));
      }
    });

    test(
      'updateCandidatesAfterPlacement should remove value from affected cells',
      () {
        final grid = SudokuGrid.empty();
        // First populate notes
        grid.autoPopulateNotes();
        // Place 5 at (0,0)
        grid.setCell(0, 0, 5);
        grid.updateCandidatesAfterPlacement(0, 0, 5);
        // Check row 0: no cell should have 5 as candidate
        for (int c = 0; c < 9; c++) {
          expect(grid.getCell(0, c).candidates, isNot(contains(5)));
        }
        // Check column 0: no cell should have 5 as candidate
        for (int r = 0; r < 9; r++) {
          expect(grid.getCell(r, 0).candidates, isNot(contains(5)));
        }
        // Check 3x3 box: cells in box should not have 5
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            expect(grid.getCell(r, c).candidates, isNot(contains(5)));
          }
        }
      },
    );
  });
}
