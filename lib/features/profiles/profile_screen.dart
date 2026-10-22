import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../../core/widgets/netrik_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageProvider);
    _nameController.text = storage.username;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(localStorageProvider);
    final winRate = storage.matchesPlayed > 0
        ? ((storage.matchesWon / storage.matchesPlayed) * 100).toInt()
        : 0;

    String tierName = 'வீரன் (Warrior)';
    Color tierColor = AppColors.gold;
    if (storage.rating >= 1500) {
      tierName = 'பேரரசன் (Emperor)';
      tierColor = AppColors.crimsonLight;
    } else if (storage.rating >= 1300) {
      tierName = 'தளபதி (Commander)';
      tierColor = AppColors.sapphireLight;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
      ),
      body: KolamBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Tier Card
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [AppColors.goldLight, AppColors.goldDark],
                        ),
                        border: Border.all(color: AppColors.ivory, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 56,
                        color: AppColors.background,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          size: 16, color: AppColors.background),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                storage.username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ivory,
                ),
              ),
              const SizedBox(height: 4),

              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tierColor, width: 1.2),
                  ),
                  child: Text(
                    tierName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Elo Rating', '${storage.rating}',
                        Icons.military_tech, AppColors.gold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Matches', '${storage.matchesPlayed}',
                        Icons.sports_esports, AppColors.sapphireLight),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Win Rate', '$winRate%',
                        Icons.trending_up, AppColors.emeraldLight),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Edit Username
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Player Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.ivory),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    NetrikButton(
                      label: 'Save Name',
                      width: double.infinity,
                      onPressed: () {
                        final newName = _nameController.text.trim();
                        if (newName.isNotEmpty) {
                          storage.username = newName;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Username updated!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Account Status info
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account & Connectivity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.wifi_off,
                            size: 16, color: AppColors.emeraldLight),
                        SizedBox(width: 8),
                        Text(
                          'Local & Offline Ready Mode active',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'User ID: ${storage.userId}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
