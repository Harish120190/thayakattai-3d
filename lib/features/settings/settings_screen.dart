import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);
    final storage = ref.watch(localStorageProvider);
    final audio = ref.watch(audioServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('settings')),
      ),
      body: KolamBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Section: Language
            Text(
              l10n.tr('language'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<AppLanguage>(
                    activeColor: AppColors.gold,
                    title: const Text('English (ஆங்கிலம்)',
                        style: TextStyle(color: AppColors.ivory)),
                    value: AppLanguage.english,
                    groupValue: lang,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(languageProvider.notifier).setLanguage(val);
                      }
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  RadioListTile<AppLanguage>(
                    activeColor: AppColors.gold,
                    title: const Text('தமிழ் (Tamil)',
                        style: TextStyle(color: AppColors.ivory)),
                    value: AppLanguage.tamil,
                    groupValue: lang,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(languageProvider.notifier).setLanguage(val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Audio & Haptics
            const Text(
              'Audio & Tactile Controls',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AppColors.gold,
                    title: Text(l10n.tr('sound_effects'),
                        style: const TextStyle(color: AppColors.ivory)),
                    subtitle: const Text('Play authentic dice roll and movement sounds',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    value: storage.soundEnabled,
                    onChanged: (val) {
                      storage.soundEnabled = val;
                      setState(() {});
                      if (val) audio.playDiceRoll();
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    activeColor: AppColors.gold,
                    title: Text(l10n.tr('haptics'),
                        style: const TextStyle(color: AppColors.ivory)),
                    subtitle: const Text('Tactile response on roll and token moves',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    value: storage.hapticsEnabled,
                    onChanged: (val) {
                      storage.hapticsEnabled = val;
                      setState(() {});
                      if (val) audio.playCapture();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: About & Heritage
            const Text(
              'About Thaya Netrik (தாய நேத்ரிக்)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Netrik.AI Traditional Games',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ivory,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thaya Netrik celebrates ancient Tamil game culture, preserving the strategic brilliance of Thayakattai with modern multiplayer engineering and clean cross-platform architecture.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.surfaceBorder),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('1.0.0 (Production Ready)',
                          style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
