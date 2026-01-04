import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
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
    final file = await _localFile(puzzle.id); // Use ID as filename
    final jsonString = jsonEncode(puzzle.toJson());
    await file.writeAsString(jsonString);
  }

  Future<Puzzle?> loadPuzzle(String filename) async {
    try {
      final file = await _localFile(filename);
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString);
      return Puzzle.fromJson(jsonMap);
    } catch (e) {
      developer.log('Error loading puzzle', error: e);
      return null;
    }
  }

  Future<List<String>> listPuzzles() async {
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
