import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/game_info.dart';
import '../../core/widgets/game_tile_card.dart';
import '../../services/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PaoloHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: GridView.builder(
            itemCount: GameCatalog.games.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final game = GameCatalog.games[index];
              return GameTileCard(
                game: game,
                bestScore: storage.getBestScore(game.storageKey),
                onTap: () => context.push(game.route),
              );
            },
          ),
        ),
      ),
    );
  }
}
