import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/models/sudoku_cell.dart';

void main() {
  group('SudokuGrid Logic', () {
    test('Empty grid should be valid', () {
      final grid = SudokuGrid.empty();
      // An empty grid is not solved, but moves should be valid
      expect(grid.isValidMove(0, 0, 1), true);
    });

    test('Row validation', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      expect(grid.isValidMove(0, 1, 5), false); // Same row
      expect(grid.isValidMove(0, 1, 6), true); // Different number
    });

    test('Column validation', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      expect(grid.isValidMove(1, 0, 5), false); // Same col
      expect(grid.isValidMove(1, 0, 6), true); // Different number
    });

    test('Box validation', () {
      final grid = SudokuGrid.empty();
      grid.setCell(0, 0, 5);
      // 1,1 is in the same 3x3 box as 0,0
      expect(grid.isValidMove(1, 1, 5), false); 
      // 0,3 is in a different box (the one to the right)
      expect(grid.isValidMove(0, 3, 5), false); // Wait, this is same row check, effectively.
      
      // Let's test box specifically where row/col are different but box is same.
      // 0,0 is top-left box.
      // 1,1 is top-left box.
      // 2,2 is top-left box.
      
      grid.setCell(0, 0, 1);
      expect(grid.isValidMove(1, 1, 1), false);
      expect(grid.isValidMove(2, 2, 1), false);
    });
  });
}
