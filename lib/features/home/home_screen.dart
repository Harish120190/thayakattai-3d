import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../friends/friends_screen.dart';
import '../game_lobby/game_lobby_screen.dart';
import '../game_mode_selection/game_mode_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../match_history/match_history_screen.dart';
import '../profiles/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../tutorial/tutorial_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final storage = ref.watch(localStorageProvider);

    return Scaffold(
      body: KolamBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Profile Pill
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.surfaceBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.gold,
                            child: Icon(Icons.person,
                                size: 18, color: AppColors.background),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storage.username,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ivory,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.military_tech,
                                      size: 13, color: AppColors.gold),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${storage.rating} Elo',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.goldLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Language Toggle & Settings
                  Row(
                    children: [
                      // Language Toggle
                      TextButton(
                        onPressed: () {
                          ref.read(languageProvider.notifier).setLanguage(
                                lang == AppLanguage.english
                                    ? AppLanguage.tamil
                                    : AppLanguage.english,
                              );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          backgroundColor:
                              AppColors.surfaceElevated.withValues(alpha: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                                color: AppColors.gold, width: 1),
                          ),
                        ),
                        child: Text(
                          lang == AppLanguage.english ? 'தமிழ்' : 'English',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.ivory),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Brand Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E1922),
                      Color(0xFF1B1833),
                      Color(0xFF0F1626),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimson.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.casino, size: 48, color: AppColors.gold),
                    const SizedBox(height: 10),
                    Text(
                      l10n.tr('app_title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.goldLight,
                            shadows: [
                              Shadow(
                                color: AppColors.gold.withValues(alpha: 0.6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tr('tagline'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Game Modes Grid
              _buildModeCard(
                context,
                title: l10n.tr('local_multiplayer'),
                subtitle:
                    'Play on 1 device with 2, 4, 6, or 8 friends / family',
                icon: Icons.people_outline,
                accentColor: AppColors.crimsonLight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const GameModeScreen(mode: GameSelectionMode.local),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildModeCard(
                context,
                title: l10n.tr('play_ai'),
                subtitle:
                    'Challenge smart AI opponents (Easy, Medium, or Hard)',
                icon: Icons.smart_toy_outlined,
                accentColor: AppColors.gold,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const GameModeScreen(mode: GameSelectionMode.ai),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildModeCard(
                context,
                title: l10n.tr('create_room'),
                subtitle:
                    'Host private multiplayer match with 6-digit room code',
                icon: Icons.meeting_room_outlined,
                accentColor: AppColors.emeraldLight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GameLobbyScreen(isHost: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _buildModeCard(
                context,
                title: l10n.tr('join_room'),
                subtitle: 'Enter room code to join an ongoing private lobby',
                icon: Icons.vpn_key_outlined,
                accentColor: AppColors.sapphireLight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GameLobbyScreen(isHost: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick Navigation Tools
              Row(
                children: [
                  Expanded(
                    child: _buildSmallQuickLink(
                      context,
                      title: l10n.tr('leaderboard'),
                      icon: Icons.leaderboard,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSmallQuickLink(
                      context,
                      title: l10n.tr('match_history'),
                      icon: Icons.history,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MatchHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallQuickLink(
                      context,
                      title: l10n.tr('friends'),
                      icon: Icons.group,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FriendsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSmallQuickLink(
                      context,
                      title: l10n.tr('tutorial'),
                      icon: Icons.school,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TutorialScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ivory,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gold, size: 24),
        ],
      ),
    );
  }

  Widget _buildSmallQuickLink(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ivory,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
