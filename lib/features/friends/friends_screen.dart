import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../game_lobby/game_lobby_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _friends = [
    {
      'name': 'Karthik Raja',
      'rating': 1420,
      'isOnline': true,
      'avatar': 'warrior'
    },
    {
      'name': 'Ananya Sundaram',
      'rating': 1380,
      'isOnline': true,
      'avatar': 'queen'
    },
    {
      'name': 'Rajesh Kumar',
      'rating': 1240,
      'isOnline': false,
      'avatar': 'king'
    },
    {
      'name': 'Priya Selvam',
      'rating': 1310,
      'isOnline': false,
      'avatar': 'sage'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('friends')),
      ),
      body: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.ivory),
                decoration: InputDecoration(
                  hintText: 'Search player by username...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    setState(() {
                      _friends.insert(0, {
                        'name': query.trim(),
                        'rating': 1200,
                        'isOnline': true,
                        'avatar': 'warrior'
                      });
                      _searchController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend request sent to $query!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Friends List (${_friends.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  itemCount: _friends.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final friend = _friends[idx];
                    final isOnline = friend['isOnline'] as bool;

                    return GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                                child: const Icon(Icons.person,
                                    color: AppColors.gold),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline
                                      ? AppColors.emeraldLight
                                      : Colors.grey,
                                  border: Border.all(
                                      color: AppColors.surface, width: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ivory,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${friend['rating']} Elo',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.goldLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isOnline
                                            ? AppColors.emeraldLight
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Challenge button
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  AppColors.gold.withValues(alpha: 0.15),
                              foregroundColor: AppColors.goldLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: AppColors.gold, width: 1),
                              ),
                            ),
                            icon: const Icon(Icons.sports_esports, size: 16),
                            label: const Text('Invite'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Invitation sent to ${friend['name']}! Launching room lobby...'),
                                ),
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const GameLobbyScreen(isHost: true),
                                ),
                              );
                            },
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
}
