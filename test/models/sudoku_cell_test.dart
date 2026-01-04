import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sudokarrow/models/sudoku_cell.dart';

void main() {
  group('SudokuCell', () {
    test(
      'should initialize with null value and empty candidates by default',
      () {
        final cell = SudokuCell();
        expect(cell.value, isNull);
        expect(cell.candidates, isEmpty);
        expect(cell.isFixed, isFalse);
      },
    );

    test('should store provided value and fixed state', () {
      final cell = SudokuCell(value: 5, isFixed: true);
      expect(cell.value, 5);
      expect(cell.isFixed, isTrue);
      cell.setValue(6); // Should not change value
      expect(cell.value, 5);
    });

    test('should allow modifying value if not fixed', () {
      final cell = SudokuCell();
      cell.value = 3;
      expect(cell.value, 3);
      cell.setValue(4); // Should change value
      expect(cell.value, 4);
    });

    test('should initialize with candidates if provided', () {
      final cell = SudokuCell(candidates: [1, 2, 3]);
      expect(cell.candidates, equals([1, 2, 3]));
    });

    test('serialization round trip should preserve properties', () {
      final originalCell = SudokuCell(
        value: 7,
        isFixed: true,
        candidates: [8, 9],
      );
      final json = originalCell.toJson();
      final revivedCell = SudokuCell.fromJson(json);

      expect(revivedCell.value, originalCell.value);
      expect(revivedCell.isFixed, originalCell.isFixed);
      // Note: Candidates are not included in SudokuCell.g.dart based on previous view which only showed value and isFixed likely being serializable if not annotated,
      // but let's check the generated file if candidates are included.
      // Looking at source code:
      // @JsonSerializable()
      // class SudokuCell { ... List<int> candidates ... }
      // candidates is a field, so it should be valid unless ignored.
      expect(revivedCell.candidates, originalCell.candidates);
    });
  });
}
