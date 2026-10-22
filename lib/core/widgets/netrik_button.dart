import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class NetrikButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final double? width;

  const NetrikButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.width,
  });

  @override
  State<NetrikButton> createState() => _NetrikButtonState();
}

class _NetrikButtonState extends State<NetrikButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: widget.isSecondary
              ? LinearGradient(
                  colors: _isHovered
                      ? [
                          AppColors.surfaceElevated,
                          AppColors.surfaceElevated.withValues(alpha: 0.9),
                        ]
                      : [
                          AppColors.surface,
                          AppColors.surfaceElevated,
                        ],
                )
              : LinearGradient(
                  colors: _isHovered
                      ? [
                          AppColors.goldLight,
                          AppColors.gold,
                        ]
                      : [
                          AppColors.gold,
                          AppColors.goldDark,
                        ],
                ),
          border: Border.all(
            color: widget.isSecondary
                ? (_isHovered ? AppColors.gold : AppColors.surfaceBorder)
                : AppColors.goldLight,
            width: widget.isSecondary ? 1.5 : 2.0,
          ),
          boxShadow: [
            if (!_isHovered && !widget.isSecondary && isEnabled)
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (_isHovered && isEnabled)
              BoxShadow(
                color: widget.isSecondary
                    ? AppColors.gold.withValues(alpha: 0.3)
                    : AppColors.gold.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize:
                    widget.width != null ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isSecondary
                          ? AppColors.gold
                          : AppColors.background,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isSecondary
                          ? AppColors.ivory
                          : AppColors.background,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
