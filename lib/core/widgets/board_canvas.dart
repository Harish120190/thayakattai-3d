import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/game_state.dart';
import '../../data/models/token.dart';
import '../../features/game_engine/board_geometry.dart';

class BoardCanvas extends StatefulWidget {
  final GameState state;
  final BoardGeometry geometry;
  final void Function(String tokenId)? onTokenTapped;

  const BoardCanvas({
    super.key,
    required this.state,
    required this.geometry,
    this.onTokenTapped,
  });

  @override
  State<BoardCanvas> createState() => _BoardCanvasState();
}

class _BoardCanvasState extends State<BoardCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep board square and perfectly fitted to available viewport
        final size = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return GestureDetector(
                  onTapUp: (details) => _handleBoardTap(details.localPosition, size),
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _BoardPainter(
                      state: widget.state,
                      geometry: widget.geometry,
                      pulseValue: _pulseController.value,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleBoardTap(Offset localPos, double boardSize) {
    if (widget.onTokenTapped == null ||
        widget.state.validMovableTokenIds.isEmpty) {
      return;
    }

    final normX = localPos.dx / boardSize;
    final normY = localPos.dy / boardSize;
    final hitRadius = 0.055; // Normalized hit box

    // Check hit against valid movable tokens
    for (final tokenId in widget.state.validMovableTokenIds) {
      final token = widget.state.tokens.firstWhere((t) => t.id == tokenId);
      Point<double> coord;

      if (token.state == TokenState.inKottam) {
        coord = widget.geometry
            .getKottamCoordinate(token.playerIndex, token.tokenIndex);
      } else if (token.state == TokenState.onTrack) {
        coord = widget.geometry.getOuterCellCoordinate(token.cellIndex);
      } else if (token.state == TokenState.onHomeStretch) {
        coord = widget.geometry
            .getHomeStretchCoordinate(token.playerIndex, token.cellIndex);
      } else {
        continue;
      }

      final dist = sqrt(pow(normX - coord.x, 2) + pow(normY - coord.y, 2));
      if (dist <= hitRadius) {
        widget.onTokenTapped!(tokenId);
        return;
      }
    }
  }
}

class _BoardPainter extends CustomPainter {
  final GameState state;
  final BoardGeometry geometry;
  final double pulseValue;

  _BoardPainter({
    required this.state,
    required this.geometry,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw outer wooden/brass board backing
    final boardRect = Rect.fromLTWH(0, 0, w, h);
    final boardBgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF222B3D),
          Color(0xFF151C2B),
          Color(0xFF0D121D),
        ],
      ).createShader(boardRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(20)),
      boardBgPaint,
    );

    // Board border with gold inlay
    final borderPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(4), const Radius.circular(16)),
      borderPaint,
    );

    // 2. Draw homeward tracks connecting outer cells to central Pazham
    _drawHomewardTracks(canvas, size);

    // 3. Draw outer track cells
    _drawOuterCells(canvas, size);

    // 4. Draw central Pazham (Mahameru victory lotus)
    _drawCentralPazham(canvas, size);

    // 5. Draw tokens
    _drawTokens(canvas, size);
  }

  void _drawOuterCells(Canvas canvas, Size size) {
    final cellRadius = size.width * (geometry.playerCount <= 4 ? 0.040 : 0.030);

    for (var i = 0; i < geometry.totalOuterCells; i++) {
      final coord = geometry.getOuterCellCoordinate(i);
      final center = Offset(coord.x * size.width, coord.y * size.height);
      final isSafe = geometry.isCellSafe(i);

      // Check if this cell is a player's entry cell
      int? entryPlayerIdx;
      for (final entry in geometry.playerEntryCells.entries) {
        if (entry.value == i) {
          entryPlayerIdx = entry.key;
          break;
        }
      }

      // Cell background
      final cellBgPaint = Paint()
        ..color = entryPlayerIdx != null
            ? AppColors.getPlayerColor(entryPlayerIdx).withValues(alpha: 0.25)
            : (isSafe
                ? AppColors.gold.withValues(alpha: 0.20)
                : AppColors.surfaceElevated.withValues(alpha: 0.85))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, cellRadius, cellBgPaint);

      // Cell border
      final cellBorderPaint = Paint()
        ..color = isSafe
            ? AppColors.goldLight
            : AppColors.surfaceBorder.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSafe ? 2.0 : 1.2;
      canvas.drawCircle(center, cellRadius, cellBorderPaint);

      // If SAFE (Malai): Draw traditional sacred cross (X) inside
      if (isSafe) {
        final crossPaint = Paint()
          ..color = AppColors.gold
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        final offset = cellRadius * 0.55;
        canvas.drawLine(
          Offset(center.dx - offset, center.dy - offset),
          Offset(center.dx + offset, center.dy + offset),
          crossPaint,
        );
        canvas.drawLine(
          Offset(center.dx - offset, center.dy + offset),
          Offset(center.dx + offset, center.dy - offset),
          crossPaint,
        );
      }
    }
  }

  void _drawHomewardTracks(Canvas canvas, Size size) {
    for (var p = 0; p < geometry.playerCount; p++) {
      final playerColor = AppColors.getPlayerColor(p);
      final stepRadius =
          size.width * (geometry.playerCount <= 4 ? 0.026 : 0.020);

      for (var s = 1; s <= geometry.homeStretchLength; s++) {
        final coord = geometry.getHomeStretchCoordinate(p, s);
        final center = Offset(coord.x * size.width, coord.y * size.height);

        final stepPaint = Paint()
          ..color = playerColor.withValues(alpha: 0.25 + (s * 0.10))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, stepRadius, stepPaint);

        final borderPaint = Paint()
          ..color = playerColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(center, stepRadius, borderPaint);
      }
    }
  }

  void _drawCentralPazham(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final pazhamRadius =
        size.width * (geometry.playerCount <= 4 ? 0.08 : 0.065);

    // Glowing lotus base
    final lotusPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.goldLight,
          AppColors.gold,
          AppColors.goldDark,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: pazhamRadius));
    canvas.drawCircle(center, pazhamRadius, lotusPaint);

    final lotusBorder = Paint()
      ..color = AppColors.ivory
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, pazhamRadius, lotusBorder);

    // Central victory star / fruit motif
    final starPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pazhamRadius * 0.45, starPaint);

    final innerStarPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pazhamRadius * 0.25, innerStarPaint);
  }

  void _drawTokens(Canvas canvas, Size size) {
    final tokenRadius =
        size.width * (geometry.playerCount <= 4 ? 0.030 : 0.022);

    for (final token in state.tokens) {
      if (token.state == TokenState.inPazham) {
        // Finished token resting in central Mahameru
        final center = Offset(size.width * 0.5, size.height * 0.5);
        final playerColor = AppColors.getPlayerColor(token.playerIndex);
        canvas.drawCircle(
          Offset(
            center.dx + (token.tokenIndex - 1.5) * 6,
            center.dy + (token.tokenIndex % 2 == 0 ? -4 : 4),
          ),
          tokenRadius * 0.6,
          Paint()..color = playerColor,
        );
        continue;
      }

      Point<double> coord;
      if (token.state == TokenState.inKottam) {
        coord = geometry.getKottamCoordinate(
            token.playerIndex, token.tokenIndex);
      } else if (token.state == TokenState.onTrack) {
        coord = geometry.getOuterCellCoordinate(token.cellIndex);
      } else {
        coord = geometry.getHomeStretchCoordinate(
            token.playerIndex, token.cellIndex);
      }

      final pos = Offset(coord.x * size.width, coord.y * size.height);
      final playerColor = AppColors.getPlayerColor(token.playerIndex);
      final isMovable = state.validMovableTokenIds.contains(token.id);

      // Pulsating aura around legal movable pieces
      if (isMovable) {
        final auraRadius = tokenRadius * (1.3 + (pulseValue * 0.3));
        final auraPaint = Paint()
          ..color = AppColors.gold.withValues(alpha: 0.45 - (pulseValue * 0.2))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, auraRadius, auraPaint);

        final ringPaint = Paint()
          ..color = AppColors.goldLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(pos, tokenRadius * 1.35, ringPaint);
      }

      // Token 3D sphere gradient
      final tokenPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            playerColor.withValues(alpha: 0.9),
            playerColor,
            Color.lerp(playerColor, Colors.black, 0.45)!,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: tokenRadius));
      canvas.drawCircle(pos, tokenRadius, tokenPaint);

      // Inlay gold/ivory rim
      final rimPaint = Paint()
        ..color = isMovable ? AppColors.goldLight : AppColors.ivory
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMovable ? 2.0 : 1.2;
      canvas.drawCircle(pos, tokenRadius, rimPaint);

      // Small central metallic jewel dot
      canvas.drawCircle(
        pos,
        tokenRadius * 0.35,
        Paint()..color = AppColors.ivory.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}
