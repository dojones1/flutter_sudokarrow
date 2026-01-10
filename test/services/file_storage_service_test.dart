import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/models/puzzle.dart';
import 'package:flutter_sudokarrow/models/sudoku_grid.dart';
import 'package:flutter_sudokarrow/services/file_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FileStorageService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sudoku_test_');
    service = FileStorageService();

    // Mock the path_provider channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  group('FileStorageService', () {
    test('savePuzzle should write json to file', () async {
      final puzzle = Puzzle(
        id: 'test_1',
        title: 'Test',
        description: 'Desc',
        grid: SudokuGrid.empty(),
      );

      await service.savePuzzle(puzzle);

      final file = File('${tempDir.path}/puzzles/test_1.json');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('"id":"test_1"'));
    });

    test('loadPuzzle should read puzzle from file', () async {
      final puzzle = Puzzle(
        id: 'saved_puzzle',
        title: 'Saved',
        description: 'Saved Desc',
        grid: SudokuGrid.empty(),
      );

      await service.savePuzzle(puzzle);
      final loaded = await service.loadPuzzle('saved_puzzle');

      expect(loaded, isNotNull);
      expect(loaded!.id, 'saved_puzzle');
      expect(loaded.title, 'Saved');
    });

    test('listPuzzles should list all json files', () async {
      final puzzlesDir = Directory('${tempDir.path}/puzzles');
      await puzzlesDir.create(recursive: true);
      File('${puzzlesDir.path}/p1.json').createSync();
      File('${puzzlesDir.path}/p2.json').createSync();
      File('${puzzlesDir.path}/not_a_puzzle.txt').createSync();

      final list = await service.listPuzzles();
      expect(list, containsAll(['p1', 'p2']));
      expect(list.contains('not_a_puzzle'), isFalse);
    });

    test('deletePuzzle should remove file', () async {
      final puzzle = Puzzle(
        id: 'to_delete',
        title: 'Delete Me',
        description: '...',
        grid: SudokuGrid.empty(),
      );

      await service.savePuzzle(puzzle);
      final file = File('${tempDir.path}/puzzles/to_delete.json');
      expect(file.existsSync(), isTrue);

      await service.deletePuzzle('to_delete');
      expect(file.existsSync(), isFalse);
    });

    test('loadPuzzle should return null for non-existing file', () async {
      final loaded = await service.loadPuzzle('non_existing');
      expect(loaded, isNull);
    });

    test('loadPuzzle should return null for invalid json', () async {
      final puzzlesDir = Directory('${tempDir.path}/puzzles');
      await puzzlesDir.create(recursive: true);
      final file = File('${puzzlesDir.path}/invalid.json');
      await file.writeAsString('invalid json');

      final loaded = await service.loadPuzzle('invalid');
      expect(loaded, isNull);
    });

    test('deletePuzzle should not throw for non-existing file', () async {
      // Should not throw
      await service.deletePuzzle('non_existing');
    });
  });
}
