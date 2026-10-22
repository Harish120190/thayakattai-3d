import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';

class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);

    final steps = [
      {
        'title': '1. The Traditional Dice (தாயக்கட்டை)',
        'tamilTitle': '1. பாரம்பரிய தாயக்கட்டை',
        'desc':
            'Played with a pair of long cuboidal brass dice. Face values: 1, 2, 3, or Blank (0).\n• (1, 0) or (0, 1) = 1 (Thayam / தாயம்)\n• (0, 0) = 12 (Panirendu / பன்னிரண்டு)\n• Sum of faces: 2, 3, 4, 5, 6.\nThrows of 1, 5, 6, and 12 award BONUS EXTRA ROLLS!',
        'icon': Icons.casino,
        'accent': AppColors.gold,
      },
      {
        'title': '2. Unlocking Tokens (காய்களை களமிறக்குதல்)',
        'tamilTitle': '2. காய்களை களமிறக்குதல்',
        'desc':
            'All your pieces start in your home base (Kottam). A piece CANNOT enter the board until you roll a Thayam (1)!\nRolling Thayam summons a piece onto your starting safe square and awards another roll!',
        'icon': Icons.login,
        'accent': AppColors.emeraldLight,
      },
      {
        'title': '3. Safe Squares (மலை / கல்)',
        'tamilTitle': '3. மலை கட்டங்கள் (பாதுகாப்பு)',
        'desc':
            'Squares marked with a Cross (X) are traditional sanctuaries called "Malai".\nPieces resting on a Malai are 100% immune to capture! Opponents\' pieces can safely share the square.',
        'icon': Icons.shield,
        'accent': AppColors.sapphireLight,
      },
      {
        'title': '4. Capturing Pieces (வெட்டு)',
        'tamilTitle': '4. வெட்டு மற்றும் கூடுதல் வாய்ப்பு',
        'desc':
            'Landing on an opponent piece on a non-safe cell captures it ("Vettu")! The opponent\'s piece is knocked back to their Kottam, and you receive an EXTRA ROLL bonus!',
        'icon': Icons.flash_on,
        'accent': AppColors.crimsonLight,
      },
      {
        'title': '5. Reaching the Goal (பழம் / வெற்றி)',
        'tamilTitle': '5. பழம் அடைந்து வெற்றி பெறுதல்',
        'desc':
            'CRUCIAL RULE: You MUST make at least one capture during the match before ANY of your pieces can turn into the inner homeward path!\nOnce inside, guide all your pieces into the central Pazham to win!',
        'icon': Icons.emoji_events,
        'accent': AppColors.goldLight,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('tutorial')),
      ),
      body: KolamBackground(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: steps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, idx) {
            final step = steps[idx];
            final accent = step['accent'] as Color;

            return GlassCard(
              border: Border.all(
                  color: accent.withValues(alpha: 0.6), width: 1.2),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step['icon'] as IconData,
                        color: accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == AppLanguage.tamil
                              ? step['tamilTitle'] as String
                              : step['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step['desc'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ivory,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
