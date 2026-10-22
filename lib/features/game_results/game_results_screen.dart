import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../../core/widgets/netrik_button.dart';
import '../../data/models/game_state.dart';
import '../game_board/game_board_screen.dart';

class GameResultsScreen extends ConsumerStatefulWidget {
  final GameState finalState;

  const GameResultsScreen({super.key, required this.finalState});

  @override
  ConsumerState<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends ConsumerState<GameResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4))..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final state = widget.finalState;
    final winnerIdx = state.winners.isNotEmpty ? state.winners.first : 0;
    final winner = state.players[winnerIdx];
    final winnerColor = AppColors.getPlayerColor(winner.playerIndex);

    return Scaffold(
      body: KolamBackground(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.gold,
                AppColors.crimson,
                AppColors.emerald,
                AppColors.sapphire,
                Colors.amber,
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Trophy Icon & Crown
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldLight,
                            AppColors.gold,
                            AppColors.goldDark,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Winner Announcement
                  Text(
                    '🎉 ${l10n.tr('winner')}! 🎉',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: winnerColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rankings Summary Card
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Final Standings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        const Divider(color: AppColors.surfaceBorder),
                        ...state.winners.asMap().entries.map((entry) {
                          final rank = entry.key + 1;
                          final pIdx = entry.value;
                          final p = state.players[pIdx];
                          final color = AppColors.getPlayerColor(pIdx);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(
                                  '#$rank',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: rank == 1
                                        ? AppColors.gold
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(radius: 6, backgroundColor: color),
                                const SizedBox(width: 8),
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.ivory,
                                  ),
                                ),
                                const Spacer(),
                                if (rank == 1)
                                  const Icon(Icons.star,
                                      size: 18, color: AppColors.gold),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  NetrikButton(
                    label: l10n.tr('play_again'),
                    icon: Icons.replay,
                    onPressed: () {
                      ref.read(gameControllerProvider.notifier).startNewGame(
                            playerCount: state.playerCount,
                            players: state.players,
                            tokensPerPlayer: state.tokensPerPlayer,
                          );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const GameBoardScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  NetrikButton(
                    label: l10n.tr('home'),
                    icon: Icons.home,
                    isSecondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
