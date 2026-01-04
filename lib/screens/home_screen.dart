import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../models/sudoku_grid.dart';
import '../providers/game_state.dart';
import '../services/file_storage_service.dart';
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
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _loadGame(id),
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
}
