import 'package:flutter/foundation.dart';
import '../models/puzzle.dart';
import '../models/sudoku_grid.dart';

enum InputMode { value, notes }

class GameState extends ChangeNotifier {
  Puzzle? _currentPuzzle;
  int? _selectedRow;
  int? _selectedCol;
  InputMode _inputMode = InputMode.value;
  bool _authorMode = false; // If true, we are setting up the initial puzzle
  int? _hintedRow;
  int? _hintedCol;
  int? _hintedValue;

  Puzzle? get currentPuzzle => _currentPuzzle;
  SudokuGrid? get grid => _currentPuzzle?.grid;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  InputMode get inputMode => _inputMode;
  bool get authorMode => _authorMode;
  bool get isSolved => _currentPuzzle?.grid.isSolved() ?? false;
  int? get hintedRow => _hintedRow;
  int? get hintedCol => _hintedCol;
  int? get hintedValue => _hintedValue;

  void startGame(Puzzle puzzle, {bool authorMode = false}) {
    _currentPuzzle = puzzle;
    _authorMode = authorMode;
    _selectedRow = null;
    _selectedCol = null;
    _inputMode = InputMode.value;
    _hintedRow = null;
    _hintedCol = null;
    _hintedValue = null;
    notifyListeners();
  }

  void getHint() {
    final hint = grid?.getHint();
    if (hint != null) {
      _hintedRow = hint['row'];
      _hintedCol = hint['col'];
      _hintedValue = hint['value'];
    } else {
      _hintedRow = null;
      _hintedCol = null;
      _hintedValue = null;
    }
    notifyListeners();
  }

  void autoPopulateNotes() {
    grid?.autoPopulateNotes();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    _hintedRow = null;
    _hintedCol = null;
    _hintedValue = null;
    notifyListeners();
  }

  void toggleInputMode() {
    _inputMode = _inputMode == InputMode.value
        ? InputMode.notes
        : InputMode.value;
    notifyListeners();
  }

  void numberInput(int number) {
    if (_currentPuzzle == null ||
        _selectedRow == null ||
        _selectedCol == null) {
      return;
    }

    final cell = _currentPuzzle!.grid.getCell(_selectedRow!, _selectedCol!);

    if (_authorMode) {
      // In author mode, we set the value and make it fixed
      cell.value = number;
      cell.isFixed = true;
      cell.candidates.clear();
    } else {
      // In play mode
      if (cell.isFixed) {
        return;
      }

      if (_inputMode == InputMode.value) {
        if (cell.value == number) {
          cell.value = null; // Toggle off
        } else {
          cell.value = number;
          cell.candidates.clear(); // Clear candidates when placing value
          // Update candidates in affected areas
          _currentPuzzle!.grid.updateCandidatesAfterPlacement(
            _selectedRow!,
            _selectedCol!,
            number,
          );
        }
      } else {
        // Notes mode
        if (cell.candidates.contains(number)) {
          cell.candidates.remove(number);
        } else {
          cell.candidates.add(number);
        }
      }
    }
    _hintedRow = null;
    _hintedCol = null;
    _hintedValue = null;
    notifyListeners();
  }

  void clearCell() {
    if (_currentPuzzle == null ||
        _selectedRow == null ||
        _selectedCol == null) {
      return;
    }
    final cell = _currentPuzzle!.grid.getCell(_selectedRow!, _selectedCol!);

    if (_authorMode) {
      cell.value = null;
      cell.isFixed = false;
    } else {
      if (cell.isFixed) {
        return;
      }
      cell.value = null;
      cell.candidates.clear();
    }
    _hintedRow = null;
    _hintedCol = null;
    _hintedValue = null;
    notifyListeners();
  }
}
