import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/game_engine/dice_engine.dart';

class DiceThrowWidget extends StatefulWidget {
  final DiceRollOutcome? currentRoll;
  final bool isRolling;
  final bool canRoll;
  final VoidCallback? onRollPressed;
  final String activePlayerName;

  const DiceThrowWidget({
    super.key,
    this.currentRoll,
    this.isRolling = false,
    this.canRoll = true,
    this.onRollPressed,
    required this.activePlayerName,
  });

  @override
  State<DiceThrowWidget> createState() => _DiceThrowWidgetState();
}

class _DiceThrowWidgetState extends State<DiceThrowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant DiceThrowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roll = widget.currentRoll;
    final d1 = roll?.die1 ?? 1;
    final d2 = roll?.die2 ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Two long rectangular Thayakattai dice side by side
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLongDie(d1, isLeft: true),
            const SizedBox(width: 14),
            _buildLongDie(d2, isLeft: false),
          ],
        ),
        const SizedBox(height: 12),

        // Outcome label banner
        if (roll != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: roll.isBonus
                    ? [
                        AppColors.gold.withValues(alpha: 0.3),
                        AppColors.crimson.withValues(alpha: 0.3),
                      ]
                    : [
                        AppColors.surfaceElevated,
                        AppColors.surface,
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: roll.isBonus ? AppColors.gold : AppColors.surfaceBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (roll.isBonus) ...[
                  const Icon(Icons.stars, color: AppColors.gold, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  '${roll.tamilName} • ${roll.traditionalName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: roll.isBonus ? AppColors.goldLight : AppColors.ivory,
                  ),
                ),
                if (roll.isBonus) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '(+1 Roll!)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emeraldLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLongDie(int dots, {required bool isLeft}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final angle = widget.isRolling
            ? (_animController.value * 2 * pi * (isLeft ? 1 : -1))
            : 0.0;

        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 38,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE6CA65), // Brass highlight
                  Color(0xFFC59B27), // Brass body
                  Color(0xFF8C6D15), // Brass shadow
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFBF0B9),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildDieFaceDots(dots),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDieFaceDots(int count) {
    if (count == 0) {
      // Traditional blank face: Ornamental subtle etched cross
      return [
        const Icon(
          Icons.close,
          size: 16,
          color: Color(0xFF5A4408),
        ),
      ];
    }

    final dots = <Widget>[];
    for (var i = 0; i < count; i++) {
      dots.add(
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF382902), // Dark engraved dot
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFBF0B9),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      );
    }
    return dots;
  }
}
