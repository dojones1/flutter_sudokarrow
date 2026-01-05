import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../models/sudoku_grid.dart';
import '../providers/game_state.dart';
import '../services/file_storage_service.dart';
import '../data/predefined_puzzles.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileStorageService _storageService = FileStorageService();
  late Future<List<String>> _puzzlesFuture;

  @override
  void initState() {
    super.initState();
    _puzzlesFuture = _storageService.listPuzzles();
  }

  void _refreshList() {
    setState(() {
      _puzzlesFuture = _storageService.listPuzzles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SudokuArrow')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _startNewGame(authorMode: false);
                      },
                      child: const Text('Play New Game (Empty)'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _startNewGame(authorMode: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Create Puzzle (Author Mode)'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Classic Puzzles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 150, // Fixed height for scrolling
                child: ListView.builder(
                  itemCount: defaultPuzzles.length,
                  itemBuilder: (context, index) {
                    final puzzle = defaultPuzzles[index];
                    return ListTile(
                      title: Text(puzzle.title),
                      subtitle: Text(puzzle.description),
                      onTap: () => _startPredefinedGame(puzzle),
                      leading: const Icon(Icons.grid_on),
                    );
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Saved Puzzles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _puzzlesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final puzzles = snapshot.data ?? [];
                    if (puzzles.isEmpty) {
                      return const Center(
                        child: Text('No saved puzzles found.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: puzzles.length,
                      itemBuilder: (context, index) {
                        final id = puzzles[index];
                        return ListTile(
                          title: Text('Puzzle: $id'),
                          onTap: () => _loadGame(id),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewGame({required bool authorMode}) async {
    final puzzle = Puzzle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: authorMode ? 'New Puzzle' : 'Play Mode',
      description: 'A fresh start',
      grid: SudokuGrid.empty(),
    );

    context.read<GameState>().startGame(puzzle, authorMode: authorMode);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
    if (!mounted) return;
    _refreshList(); // Refresh list on return
  }

  void _loadGame(String id) async {
    final puzzle = await _storageService.loadPuzzle(id);
    if (puzzle != null && mounted) {
      context.read<GameState>().startGame(puzzle, authorMode: false);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
      if (!mounted) return;
      _refreshList();
    }
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Puzzle'),
        content: const Text('Are you sure you want to delete this puzzle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deletePuzzle(id);
      if (mounted) _refreshList();
    }
  }

  void _startPredefinedGame(Puzzle puzzle) async {
    // We pass a copy or rely on game state to not mutate the global defaultPuzzles definitions permanently if we don't want to.
    // GameState usually clones or uses the grid. To be safe, we could clone.
    // However, SudokuGrid isn't immutable, and GameState might modify it.
    // Let's create a fresh copy from the fixed values to ensure the "Template" remains clean.
    // Actually, serializing/deserializing is a cheap way to clone deeply.
    final freshPuzzle = Puzzle.fromJson(puzzle.toJson());
    // Give it a unique ID so if they save it, it doesn't try to overwrite a "classic" id or something (though save mechanism uses id).
    // If we keep the same ID, "saving" might imply updating their progress on that classic puzzle.
    // Let's keep the ID. If they save, it will create a file with that ID.
    // When they reload, they load from file.
    // BUT: If they load from file, they get the saved version.
    // If they click "Classic Puzzle 1" again, do they get a fresh one or the saved one?
    // Current UI logic: "Classic Puzzles" list always loads *fresh* from `defaultPuzzles`.
    // "Saved Puzzles" loads from file.
    // If user wants to resume classic puzzle, they should look in "Saved".
    // So, we treat clicking on Classic as "Start New Run of Classic".
    // To avoid ID collision with a saved progress file (which would be weird if we didn't load it),
    // maybe we should separate IDs or check if a save exists?
    // For simplicity: We'll let them start fresh. If they save, it saves.
    // If they want to resume, they go to Saved Puzzles logic.

    context.read<GameState>().startGame(freshPuzzle, authorMode: false);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
    if (mounted) _refreshList();
  }
}
