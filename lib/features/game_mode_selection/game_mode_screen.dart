import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../../core/widgets/netrik_button.dart';
import '../../data/models/player.dart';
import '../game_board/game_board_screen.dart';

enum GameSelectionMode {
  local,
  ai,
}

class GameModeScreen extends ConsumerStatefulWidget {
  final GameSelectionMode mode;

  const GameModeScreen({super.key, required this.mode});

  @override
  ConsumerState<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends ConsumerState<GameModeScreen> {
  int _selectedPlayerCount = 4;
  int _tokensPerPlayer = 4;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;
  bool _requireCapture = true;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final isAI = widget.mode == GameSelectionMode.ai;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAI ? l10n.tr('play_ai') : l10n.tr('local_multiplayer'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section: Player Count
                      Text(
                        l10n.tr('select_players'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [2, 4, 6, 8].map((count) {
                          final isSelected = _selectedPlayerCount == count;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(() {
                                  _selectedPlayerCount = count;
                                  // For 6 or 8 players, default 2 or 3 tokens for smooth pacing
                                  if (count >= 6 && _tokensPerPlayer > 3) {
                                    _tokensPerPlayer = 3;
                                  }
                                }),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.gold.withValues(alpha: 0.2)
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.gold
                                          : AppColors.surfaceBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.goldLight
                                              : AppColors.ivory,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Players',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? AppColors.goldLight
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Section: Tokens per player
                      const Text(
                        'Tokens per Player (காய்கள்)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [2, 3, 4].map((tCount) {
                          final isSelected = _tokensPerPlayer == tCount;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    setState(() => _tokensPerPlayer = tCount),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.gold.withValues(alpha: 0.2)
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.gold
                                          : AppColors.surfaceBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$tCount Tokens',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.goldLight
                                          : AppColors.ivory,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // If AI mode: Difficulty selector
                      if (isAI) ...[
                        const Text(
                          'AI Difficulty (கணினி நிலை)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            AIDifficulty.easy,
                            AIDifficulty.medium,
                            AIDifficulty.hard
                          ].map((diff) {
                            final isSelected = _aiDifficulty == diff;
                            final name = diff.name[0].toUpperCase() +
                                diff.name.substring(1);
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () =>
                                      setState(() => _aiDifficulty = diff),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.crimson
                                              .withValues(alpha: 0.3)
                                          : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.crimsonLight
                                            : AppColors.surfaceBorder,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.ivory
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Rule Option: Require capture to enter home lane
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.gold,
                          title: Text(
                            l10n.tr('rules_variation'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ivory,
                            ),
                          ),
                          subtitle: const Text(
                            'Must capture an opponent token before heading to Pazham (Center)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          value: _requireCapture,
                          onChanged: (val) =>
                              setState(() => _requireCapture = val),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Start Match Button
              NetrikButton(
                label: l10n.tr('start_game'),
                icon: Icons.play_arrow,
                onPressed: _startMatch,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatch() {
    final storage = ref.read(localStorageProvider);
    final players = <PlayerModel>[];
    final isAI = widget.mode == GameSelectionMode.ai;

    for (var i = 0; i < _selectedPlayerCount; i++) {
      final isHuman = (i == 0) || (!isAI);
      final playerName = isHuman
          ? (i == 0 ? storage.username : 'Player ${i + 1}')
          : 'AI Bot ${i + 1}';

      players.add(PlayerModel(
        id: 'p_$i',
        name: playerName,
        colorHex: '#${AppColors.getPlayerColor(i).toARGB32().toRadixString(16)}',
        playerIndex: i,
        isAI: !isHuman,
        aiDifficulty: _aiDifficulty,
      ));
    }

    ref.read(gameControllerProvider.notifier).startNewGame(
          playerCount: _selectedPlayerCount,
          players: players,
          tokensPerPlayer: _tokensPerPlayer,
          requireCapture: _requireCapture,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameBoardScreen()),
    );
  }
}
