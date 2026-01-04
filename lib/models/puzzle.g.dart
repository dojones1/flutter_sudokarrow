// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Puzzle _$PuzzleFromJson(Map<String, dynamic> json) => Puzzle(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  grid: SudokuGrid.fromJson(json['grid'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PuzzleToJson(Puzzle instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'grid': instance.grid.toJson(),
};
