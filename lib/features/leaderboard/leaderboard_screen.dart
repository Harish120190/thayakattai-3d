import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final storage = ref.watch(localStorageProvider);

    // Dynamic mock and local rankings
    final entries = [
      {
        'rank': 1,
        'name': 'வேல்முருகன் (Velmurugan)',
        'rating': 1680,
        'wins': 92,
        'winRate': '78%'
      },
      {
        'rank': 2,
        'name': 'அருண்மொழி (Arunmozhi)',
        'rating': 1590,
        'wins': 84,
        'winRate': '72%'
      },
      {
        'rank': 3,
        'name': 'Sundar Pichai (Thaya King)',
        'rating': 1520,
        'wins': 76,
        'winRate': '69%'
      },
      {
        'rank': 4,
        'name': '${storage.username} (You)',
        'rating': storage.rating,
        'wins': storage.matchesWon,
        'winRate': storage.matchesPlayed > 0
            ? '${((storage.matchesWon / storage.matchesPlayed) * 100).toInt()}%'
            : '0%'
      },
      {
        'rank': 5,
        'name': 'குந்தவை (Kundavai)',
        'rating': 1340,
        'wins': 52,
        'winRate': '63%'
      },
      {
        'rank': 6,
        'name': 'Madurai Veeran',
        'rating': 1290,
        'wins': 45,
        'winRate': '58%'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('leaderboard')),
      ),
      body: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Podiums Banner
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Rank 2
                    _buildPodiumPillar(
                      rank: 2,
                      name: 'அருண்மொழி',
                      score: '1590',
                      color: const Color(0xFFC0C0C0), // Silver
                      height: 80,
                    ),
                    // Rank 1
                    _buildPodiumPillar(
                      rank: 1,
                      name: 'வேல்முருகன்',
                      score: '1680',
                      color: AppColors.gold, // Gold
                      height: 110,
                    ),
                    // Rank 3
                    _buildPodiumPillar(
                      rank: 3,
                      name: 'Sundar',
                      score: '1520',
                      color: const Color(0xFFCD7F32), // Bronze
                      height: 65,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Full Rankings List
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final item = entries[idx];
                    final isUser = (item['name'] as String).contains('(You)');
                    final rank = item['rank'] as int;

                    return GlassCard(
                      backgroundColor: isUser
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : null,
                      border: isUser
                          ? Border.all(color: AppColors.gold, width: 1.5)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: rank <= 3
                                    ? AppColors.gold
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isUser
                                        ? AppColors.goldLight
                                        : AppColors.ivory,
                                  ),
                                ),
                                Text(
                                  'Wins: ${item['wins']} • Win Rate: ${item['winRate']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.surfaceBorder, width: 1),
                            ),
                            child: Text(
                              '${item['rating']} Elo',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPodiumPillar({
    required int rank,
    required String name,
    required String score,
    required Color color,
    required double height,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.military_tech, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.ivory,
          ),
        ),
        Text(
          score,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
