import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/puzzle.dart';

class FileStorageService {
  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath();
    final puzzlesDir = Directory('$path/puzzles');
    if (!await puzzlesDir.exists()) {
      await puzzlesDir.create(recursive: true);
    }
    return File('$path/puzzles/$filename.json');
  }

  Future<void> savePuzzle(Puzzle puzzle) async {
    final jsonString = jsonEncode(puzzle.toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      // Prefix keys to avoid collisions and easily list them
      await prefs.setString('puzzle_${puzzle.id}', jsonString);
    } else {
      final file = await _localFile(puzzle.id);
      await file.writeAsString(jsonString);
    }
  }

  Future<Puzzle?> loadPuzzle(String filename) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('puzzle_$filename');
        if (jsonString == null) return null;
        final jsonMap = jsonDecode(jsonString);
        return Puzzle.fromJson(jsonMap);
      } else {
        final file = await _localFile(filename);
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString);
        return Puzzle.fromJson(jsonMap);
      }
    } catch (e) {
      developer.log('Error loading puzzle', error: e);
      return null;
    }
  }

  Future<List<String>> listPuzzles() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs
          .getKeys()
          .where((key) => key.startsWith('puzzle_'))
          .map((key) => key.replaceFirst('puzzle_', ''))
          .toList();
    } else {
      final path = await _localPath();
      final puzzlesDir = Directory('$path/puzzles');
      if (!await puzzlesDir.exists()) return [];

      final entities = await puzzlesDir.list().toList();
      return entities
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
          .toList();
    }
  }

  Future<void> deletePuzzle(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('puzzle_$id');
    } else {
      final file = await _localFile(id);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
