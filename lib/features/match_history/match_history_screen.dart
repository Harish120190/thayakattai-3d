import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final storage = ref.watch(localStorageProvider);
    final history = storage.matchHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('match_history')),
      ),
      body: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_toggle_off,
                          size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'No matches played yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ivory,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start a Local Pass & Play or AI match to build your history!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final item = history[idx];
                    final isWon = item['isHumanWon'] as bool? ?? false;
                    final winner = item['winner'] as String? ?? 'Player';
                    final pCount = item['playerCount'] as int? ?? 4;
                    final durationSec = item['durationSeconds'] as int? ?? 0;
                    final mins = durationSec ~/ 60;
                    final secs = durationSec % 60;

                    return GlassCard(
                      border: Border.all(
                        color: isWon
                            ? AppColors.emerald.withValues(alpha: 0.6)
                            : AppColors.surfaceBorder,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isWon
                                  ? AppColors.emerald.withValues(alpha: 0.2)
                                  : AppColors.crimson.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              isWon ? Icons.emoji_events : Icons.close,
                              color: isWon
                                  ? AppColors.emeraldLight
                                  : AppColors.crimsonLight,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isWon ? 'Victory!' : 'Finished',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isWon
                                        ? AppColors.emeraldLight
                                        : AppColors.ivory,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Winner: $winner • $pCount Players',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${mins}m ${secs}s',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
