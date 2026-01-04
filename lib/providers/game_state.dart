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

  Puzzle? get currentPuzzle => _currentPuzzle;
  SudokuGrid? get grid => _currentPuzzle?.grid;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  InputMode get inputMode => _inputMode;
  bool get authorMode => _authorMode;
  bool get isSolved => _currentPuzzle?.grid.isSolved() ?? false;

  void startGame(Puzzle puzzle, {bool authorMode = false}) {
    _currentPuzzle = puzzle;
    _authorMode = authorMode;
    _selectedRow = null;
    _selectedCol = null;
    _inputMode = InputMode.value;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void toggleInputMode() {
    _inputMode = _inputMode == InputMode.value ? InputMode.notes : InputMode.value;
    notifyListeners();
  }

  void numberInput(int number) {
    if (_currentPuzzle == null || _selectedRow == null || _selectedCol == null) return;
    
    final cell = _currentPuzzle!.grid.getCell(_selectedRow!, _selectedCol!);

    if (_authorMode) {
        // In author mode, we set the value and make it fixed
        cell.value = number;
        cell.isFixed = true;
        cell.candidates.clear();
    } else {
        // In play mode
        if (cell.isFixed) return;

        if (_inputMode == InputMode.value) {
            if (cell.value == number) {
                cell.value = null; // Toggle off
            } else {
                cell.value = number;
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
    notifyListeners();
  }

  void clearCell() {
    if (_currentPuzzle == null || _selectedRow == null || _selectedCol == null) return;
    final cell = _currentPuzzle!.grid.getCell(_selectedRow!, _selectedCol!);
    
    if (_authorMode) {
        cell.value = null;
        cell.isFixed = false;
    } else {
        if (cell.isFixed) return;
        cell.value = null;
        cell.candidates.clear();
    }
    notifyListeners();
  }
}
