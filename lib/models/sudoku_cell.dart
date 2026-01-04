import 'package:json_annotation/json_annotation.dart';

part 'sudoku_cell.g.dart';

@JsonSerializable()
class SudokuCell {
  /// The number placed in the cell (1-9), or null if empty.
  int? value;

  /// Whether this cell is part of the initial puzzle (cannot be changed).
  bool isFixed;

  /// User-annotated possible values (candidates/notes).
  List<int> candidates;

  SudokuCell({
    this.value,
    this.isFixed = false,
    List<int>? candidates,
  }) : candidates = candidates ?? [];

  factory SudokuCell.fromJson(Map<String, dynamic> json) =>
      _$SudokuCellFromJson(json);

  Map<String, dynamic> toJson() => _$SudokuCellToJson(this);
}
