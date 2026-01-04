// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_grid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SudokuGrid _$SudokuGridFromJson(Map<String, dynamic> json) => SudokuGrid(
  rows: (json['rows'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>)
            .map((e) => SudokuCell.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      .toList(),
);

Map<String, dynamic> _$SudokuGridToJson(
  SudokuGrid instance,
) => <String, dynamic>{
  'rows': instance.rows.map((e) => e.map((e) => e.toJson()).toList()).toList(),
};
