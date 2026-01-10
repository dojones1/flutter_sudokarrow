import 'package:flutter/foundation.dart';
import '../models/puzzle.dart';
import '../models/sudoku_grid.dart';

enum InputMode { value, notes }

class Move {
  final int row;
  final int col;
  final int? oldValue;
  final int? newValue;

  Move(this.row, this.col, this.oldValue, this.newValue);
}

class GameState extends ChangeNotifier {
  Puzzle? _currentPuzzle;
  int? _selectedRow;
  int? _selectedCol;
  InputMode _inputMode = InputMode.value;
  bool _authorMode = false; // If true, we are setting up the initial puzzle
  final List<Move> _moves = [];
  bool _showCandidates = true;
  bool _showHighlights = true;

  Puzzle? get currentPuzzle => _currentPuzzle;
  SudokuGrid? get grid => _currentPuzzle?.grid;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  InputMode get inputMode => _inputMode;
  bool get authorMode => _authorMode;
  bool get isSolved => _currentPuzzle?.grid.isSolved() ?? false;
  bool get canUndo => _moves.isNotEmpty;
  bool get showCandidates => _showCandidates;
  bool get showHighlights => _showHighlights;

  void startGame(Puzzle puzzle, {bool authorMode = false}) {
    _currentPuzzle = puzzle;
    _authorMode = authorMode;
    _selectedRow = null;
    _selectedCol = null;
    _inputMode = InputMode.value;
    _moves.clear();
    notifyListeners();
  }

  void autoPopulateNotes() {
    grid?.autoPopulateNotes();
    notifyListeners();
  }

  void undo() {
    if (_moves.isNotEmpty) {
      final move = _moves.removeLast();
      final cell = _currentPuzzle!.grid.getCell(move.row, move.col);
      cell.value = move.oldValue;
      // If undoing a placement, add back the value to candidates in affected areas
      if (move.oldValue == null && move.newValue != null) {
        _currentPuzzle!.grid.updateCandidatesAfterRemoval(
          move.row,
          move.col,
          move.newValue!,
        );
      }
      notifyListeners();
    }
  }

  void toggleCandidatesVisibility() {
    _showCandidates = !_showCandidates;
    notifyListeners();
  }

  void toggleHighlights() {
    _showHighlights = !_showHighlights;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
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
          final oldVal = cell.value;
          cell.value = number;
          cell.candidates.clear(); // Clear candidates when placing value
          // Update candidates in affected areas
          _currentPuzzle!.grid.updateCandidatesAfterPlacement(
            _selectedRow!,
            _selectedCol!,
            number,
          );
          // Record move for undo
          if (oldVal != number) {
            _moves.add(Move(_selectedRow!, _selectedCol!, oldVal, number));
          }
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
    notifyListeners();
  }
}
