import 'dart:math';

/// Board geometry and path definitions for Thayakattai across 2, 4, 6, and 8 players.
class BoardGeometry {
  final int playerCount;
  final int totalOuterCells;
  final int homeStretchLength;
  final Set<int> safeCellIndices;
  final Map<int, int> playerEntryCells;

  BoardGeometry._({
    required this.playerCount,
    required this.totalOuterCells,
    required this.homeStretchLength,
    required this.safeCellIndices,
    required this.playerEntryCells,
  });

  factory BoardGeometry.forPlayerCount(int count) {
    switch (count) {
      case 2:
        return BoardGeometry._(
          playerCount: 2,
          totalOuterCells: 24,
          homeStretchLength: 4,
          safeCellIndices: {0, 6, 12, 18},
          playerEntryCells: {0: 0, 1: 12}, // Opposite entries
        );
      case 4:
        return BoardGeometry._(
          playerCount: 4,
          totalOuterCells: 24,
          homeStretchLength: 4,
          safeCellIndices: {0, 6, 12, 18},
          playerEntryCells: {0: 0, 1: 6, 2: 12, 3: 18}, // 4 directions
        );
      case 6:
        return BoardGeometry._(
          playerCount: 6,
          totalOuterCells: 36,
          homeStretchLength: 4,
          safeCellIndices: {0, 6, 12, 18, 24, 30},
          playerEntryCells: {
            0: 0,
            1: 6,
            2: 12,
            3: 18,
            4: 24,
            5: 30,
          }, // 6-way hexagonal
        );
      case 8:
        return BoardGeometry._(
          playerCount: 8,
          totalOuterCells: 48,
          homeStretchLength: 4,
          safeCellIndices: {0, 6, 12, 18, 24, 30, 36, 42},
          playerEntryCells: {
            0: 0,
            1: 6,
            2: 12,
            3: 18,
            4: 24,
            5: 30,
            6: 36,
            7: 42,
          }, // 8-way octagonal
        );
      default:
        return BoardGeometry.forPlayerCount(4);
    }
  }

  /// Whether a specific outer cell index is a safe square (Malai / Kallu).
  bool isCellSafe(int cellIndex) => safeCellIndices.contains(cellIndex);

  /// Total steps needed from entry to reach the central Pazham.
  int get totalStepsToFinish => totalOuterCells + homeStretchLength;

  /// Returns normalized 2D point (x, y) for cell rendering on a unit canvas (0.0 to 1.0).
  Point<double> getOuterCellCoordinate(int cellIndex) {
    if (playerCount == 2 || playerCount == 4) {
      // 24 cells arranged in a perimeter rectangle:
      // 7 cells per side: 0..6 bottom (left to right), 6..12 right (bottom to top),
      // 12..18 top (right to left), 18..23 left (top to bottom).
      const margin = 0.10;
      const span = 0.80;
      const step = span / 6;

      if (cellIndex <= 6) {
        // Bottom edge
        final x = margin + cellIndex * step;
        final y = margin + span;
        return Point(x, y);
      } else if (cellIndex <= 12) {
        // Right edge
        final offset = cellIndex - 6;
        final x = margin + span;
        final y = margin + span - (offset * step);
        return Point(x, y);
      } else if (cellIndex <= 18) {
        // Top edge
        final offset = cellIndex - 12;
        final x = margin + span - (offset * step);
        final y = margin;
        return Point(x, y);
      } else {
        // Left edge
        final offset = cellIndex - 18;
        final x = margin;
        final y = margin + (offset * step);
        return Point(x, y);
      }
    } else {
      // Radial ring for 6 and 8 player mandala boards
      final angle = (cellIndex / totalOuterCells) * 2 * pi - (pi / 2);
      const radius = 0.40;
      final x = 0.5 + radius * cos(angle);
      final y = 0.5 + radius * sin(angle);
      return Point(x, y);
    }
  }

  /// Returns normalized 2D coordinate for a token in the homeward stretch.
  Point<double> getHomeStretchCoordinate(int playerIndex, int homeStep) {
    // Center is at (0.5, 0.5)
    final entryIdx = playerEntryCells[playerIndex] ?? 0;
    final outerCoord = getOuterCellCoordinate(entryIdx);

    // Interpolate from outer entry toward center (0.5, 0.5)
    final t = homeStep / (homeStretchLength + 1);
    final x = outerCoord.x + (0.5 - outerCoord.x) * t;
    final y = outerCoord.y + (0.5 - outerCoord.y) * t;
    return Point(x, y);
  }

  /// Returns normalized 2D coordinate for the player's Kottam (base yard).
  Point<double> getKottamCoordinate(int playerIndex, int tokenIndex) {
    final entryIdx = playerEntryCells[playerIndex] ?? 0;
    final outerCoord = getOuterCellCoordinate(entryIdx);

    // Place slightly outward from entry coordinate
    final angle = atan2(outerCoord.y - 0.5, outerCoord.x - 0.5);
    final dist = (playerCount <= 4) ? 0.08 : 0.06;
    final offsetX = (tokenIndex % 2 == 0 ? -0.025 : 0.025);
    final offsetY = (tokenIndex < 2 ? -0.025 : 0.025);

    final x = (outerCoord.x + dist * cos(angle) + offsetX).clamp(0.04, 0.96);
    final y = (outerCoord.y + dist * sin(angle) + offsetY).clamp(0.04, 0.96);
    return Point(x, y);
  }

  /// The Center (Pazham / Mahameru).
  static const Point<double> centerCoordinate = Point(0.5, 0.5);
}
