import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/board_canvas.dart';
import '../../core/widgets/dice_throw_widget.dart';
import '../../core/widgets/kolam_background.dart';
import '../../core/widgets/netrik_button.dart';
import '../../data/models/game_state.dart';
import '../game_results/game_results_screen.dart';

class GameBoardScreen extends ConsumerStatefulWidget {
  const GameBoardScreen({super.key});

  @override
  ConsumerState<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends ConsumerState<GameBoardScreen> {
  bool _navigatedToResults = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final rules = controller.currentRules;
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);

    if (state == null || rules == null) {
      return Scaffold(
        body: KolamBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No active game'),
                const SizedBox(height: 12),
                NetrikButton(
                  label: 'Return to Home',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check match completion
    if (state.isOver && !_navigatedToResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_navigatedToResults && mounted) {
          _navigatedToResults = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GameResultsScreen(finalState: state),
            ),
          );
        }
      });
    }

    final activePlayer = state.activePlayer;
    final playerColor = AppColors.getPlayerColor(activePlayer.playerIndex);
    final isWaitingForRoll = state.turnPhase == TurnPhase.waitingForRoll;
    final isWaitingForMove = state.turnPhase == TurnPhase.waitingForMove;
    final isHumanTurn = !activePlayer.isAI;

    return Scaffold(
      body: KolamBackground(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ivory),
                    onPressed: () => _confirmExit(context),
                  ),
                  const Spacer(),

                  // Active Player Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: playerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: playerColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: playerColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activePlayer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ivory,
                          ),
                        ),
                        if (activePlayer.isAI) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.smart_toy,
                              size: 14, color: AppColors.gold),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          activePlayer.hasCaptured
                              ? '⚔️ (Vettu ✓)'
                              : '⚔️ (Needs Vettu)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: activePlayer.hasCaptured
                                ? AppColors.emeraldLight
                                : AppColors.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.gold),
                    onPressed: () => _showRulesDialog(context),
                  ),
                ],
              ),
            ),

            // Dynamic Board Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BoardCanvas(
                  state: state,
                  geometry: rules.geometry,
                  onTokenTapped: (tokenId) {
                    if (isHumanTurn && isWaitingForMove) {
                      controller.selectToken(tokenId);
                    }
                  },
                ),
              ),
            ),

            // Bottom Console & Dice Throw Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event Message Banner
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        lang == AppLanguage.tamil
                            ? state.lastEventTamilMessage
                            : state.lastEventMessage,
                        key: ValueKey(state.lastEventMessage),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Thayakattai Dice Display
                    DiceThrowWidget(
                      currentRoll: state.currentRoll,
                      activePlayerName: activePlayer.name,
                    ),
                    const SizedBox(height: 12),

                    // Roll / Move Action Prompt
                    if (isHumanTurn) ...[
                      if (isWaitingForRoll)
                        NetrikButton(
                          label: l10n.tr('roll_dice'),
                          icon: Icons.casino,
                          width: double.infinity,
                          onPressed: () => controller.rollDice(),
                        )
                      else if (isWaitingForMove)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.tr('select_piece'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldLight,
                            ),
                          ),
                        ),
                    ] else ...[
                      // AI thinking indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${activePlayer.name} is thinking...',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Leave Match?'),
        content: const Text('Are you sure you want to exit the current game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay', style: TextStyle(color: AppColors.gold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit Game',
                style: TextStyle(color: AppColors.crimsonLight)),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Thayakattai Rules Quick Guide',
            style: TextStyle(color: AppColors.gold)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Thayam (1): Required to unlock pieces from Kottam into play.',
                  style: TextStyle(color: AppColors.ivory, fontSize: 13)),
              SizedBox(height: 6),
              Text('• Bonus Rolls: Rolling 1, 5, 6, or 12 grants an extra turn!',
                  style: TextStyle(color: AppColors.ivory, fontSize: 13)),
              SizedBox(height: 6),
              Text('• Malai (Safe Squares): Cells marked with X are completely safe from capture.',
                  style: TextStyle(color: AppColors.ivory, fontSize: 13)),
              SizedBox(height: 6),
              Text('• Vettu (Capture): Landing on an opponent sends them back to Kottam and gives you +1 extra roll!',
                  style: TextStyle(color: AppColors.ivory, fontSize: 13)),
              SizedBox(height: 6),
              Text('• Pazham (Goal): You must capture at least 1 piece to enter the central homeward path!',
                  style: TextStyle(color: AppColors.ivory, fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}
