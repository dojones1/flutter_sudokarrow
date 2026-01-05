import 'package:json_annotation/json_annotation.dart';
import 'sudoku_cell.dart';

part 'sudoku_grid.g.dart';

@JsonSerializable(explicitToJson: true)
class SudokuGrid {
  // 9x9 grid, stored as a flat list of 81 cells for simplicity,
  // or a list of lists. A flat list is easier to serialize.
  // We'll use a list of lists for easier access: grid[row][col].
  // Wait, JSON serialization of nested lists is fine.
  final List<List<SudokuCell>> rows;

  SudokuGrid({required this.rows}) {
    if (rows.length != 9 || rows.any((row) => row.length != 9)) {
      throw ArgumentError('Grid must be 9x9');
    }
  }

  factory SudokuGrid.empty() {
    return SudokuGrid(
      rows: List.generate(9, (_) => List.generate(9, (_) => SudokuCell())),
    );
  }

  factory SudokuGrid.fromFixedValues(List<List<int>> values) {
    if (values.length != 9 || values.any((row) => row.length != 9)) {
      throw ArgumentError('Values must be 9x9');
    }
    return SudokuGrid(
      rows: List.generate(
        9,
        (r) => List.generate(9, (c) {
          final val = values[r][c];
          if (val != 0) {
            return SudokuCell(value: val, isFixed: true);
          }
          return SudokuCell();
        }),
      ),
    );
  }

  factory SudokuGrid.fromJson(Map<String, dynamic> json) =>
      _$SudokuGridFromJson(json);

  Map<String, dynamic> toJson() => _$SudokuGridToJson(this);

  /// Helper to get a cell safely
  SudokuCell getCell(int row, int col) => rows[row][col];

  /// Set a value in the grid
  void setCell(int row, int col, int? value) {
    if (rows[row][col].isFixed) return;
    rows[row][col].value = value;
  }

  /// Check if the current value at [row, col] is valid with respect to the rest of the board.
  /// This checks if the value exists elsewhere in the same row, col, or box.
  bool isValidMove(int row, int col, int value) {
    // Check Row
    for (int c = 0; c < 9; c++) {
      if (c == col) continue;
      if (rows[row][c].value == value) return false;
    }

    // Check Column
    for (int r = 0; r < 9; r++) {
      if (r == row) continue;
      if (rows[r][col].value == value) return false;
    }

    // Check 3x3 Box
    int boxStartRow = (row ~/ 3) * 3;
    int boxStartCol = (col ~/ 3) * 3;

    for (int r = boxStartRow; r < boxStartRow + 3; r++) {
      for (int c = boxStartCol; c < boxStartCol + 3; c++) {
        if (r == row && c == col) continue;
        if (rows[r][c].value == value) return false;
      }
    }

    return true;
  }

  /// Check if the board is completely filled and valid.
  bool isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        int? val = rows[r][c].value;
        if (val == null) return false;
        if (!isValidMove(r, c, val)) return false;
      }
    }
    return true;
  }
}
