// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SudokuCell _$SudokuCellFromJson(Map<String, dynamic> json) => SudokuCell(
  value: (json['value'] as num?)?.toInt(),
  isFixed: json['isFixed'] as bool? ?? false,
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$SudokuCellToJson(SudokuCell instance) =>
    <String, dynamic>{
      'value': instance.value,
      'isFixed': instance.isFixed,
      'candidates': instance.candidates,
    };
