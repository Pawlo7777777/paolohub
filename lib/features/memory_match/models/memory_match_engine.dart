/// Pure game logic for Memory Match — no Flutter imports.
library;

enum MemoryDifficulty { fourByFour, sixBySix }

extension MemoryDifficultyX on MemoryDifficulty {
  int get columns => this == MemoryDifficulty.fourByFour ? 4 : 6;

  /// 4x4 = 16 cards = 8 pairs. 6x6 = 36 cards = 18 pairs.
  int get pairCount => this == MemoryDifficulty.fourByFour ? 8 : 18;

  String get label =>
      this == MemoryDifficulty.fourByFour ? '4 × 4 · Easy' : '6 × 6 · Hard';

  /// Storage key for this difficulty's best (fastest) completion time.
  String get storageKey => this == MemoryDifficulty.fourByFour
      ? 'best_time_memory_match_4x4'
      : 'best_time_memory_match_6x6';
}

/// One card in the grid. `symbol` is duplicated across exactly 2 cards
/// (its pair); `matched` is true once both have been found.
class MemoryMatchCard {
  MemoryMatchCard(this.symbol);
  final String symbol;
  bool matched = false;
}

/// A pool of emoji faces used as card fronts — offline, no image assets
/// needed. 18 entries covers the largest board (6x6 = 18 pairs).
const List<String> _symbolPool = [
  '🍎', '🍌', '🍇', '🍉', '🍓', '🍒',
  '🍑', '🥝', '🍍', '🥥', '🍋', '🥭',
  '🍏', '🥕', '🌽', '🍅', '🍆', '⭐',
];

class MemoryMatchEngine {
  MemoryMatchEngine(this.difficulty) : cards = _buildDeck(difficulty);

  final MemoryDifficulty difficulty;
  final List<MemoryMatchCard> cards;

  int moves = 0;

  int get totalPairs => difficulty.pairCount;
  int get matchedPairs => cards.where((c) => c.matched).length ~/ 2;
  bool get isComplete => matchedPairs == totalPairs;

  bool isMatch(int a, int b) => cards[a].symbol == cards[b].symbol;

  void markMatched(int a, int b) {
    cards[a].matched = true;
    cards[b].matched = true;
  }

  void registerMove() => moves++;

  static List<MemoryMatchCard> _buildDeck(MemoryDifficulty difficulty) {
    final symbols = _symbolPool.take(difficulty.pairCount).toList();
    final deck = [...symbols, ...symbols].map(MemoryMatchCard.new).toList();
    deck.shuffle();
    return deck;
  }
}
