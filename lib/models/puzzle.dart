import 'package:json_annotation/json_annotation.dart';
import 'sudoku_grid.dart';

part 'puzzle.g.dart';

@JsonSerializable(explicitToJson: true)
class Puzzle {
  String id;
  String title;
  String description;
  SudokuGrid grid;

  Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.grid,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleToJson(this);
}
