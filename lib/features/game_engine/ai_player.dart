import 'dart:math';
import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/token.dart';
import 'rules_engine.dart';

class AIPlayer {
  final AIDifficulty difficulty;
  final Random random;

  AIPlayer({
    this.difficulty = AIDifficulty.medium,
    Random? random,
  }) : random = random ?? Random();

  /// Chooses the optimal token ID from the valid movable candidates.
  String chooseMove(
    GameState state,
    RulesEngine rules,
    List<String> validTokenIds,
  ) {
    if (validTokenIds.isEmpty) {
      throw ArgumentError('Cannot choose a move when no valid tokens exist');
    }

    if (validTokenIds.length == 1) {
      return validTokenIds.first;
    }

    switch (difficulty) {
      case AIDifficulty.easy:
        return _chooseEasy(validTokenIds);
      case AIDifficulty.medium:
        return _chooseMedium(state, rules, validTokenIds);
      case AIDifficulty.hard:
        return _chooseHard(state, rules, validTokenIds);
    }
  }

  /// Easy AI: Picks randomly or advances any active piece.
  String _chooseEasy(List<String> validTokenIds) {
    return validTokenIds[random.nextInt(validTokenIds.length)];
  }

  /// Medium AI: Evaluates captures, piece entries, and safe squares.
  String _chooseMedium(
    GameState state,
    RulesEngine rules,
    List<String> validTokenIds,
  ) {
    String bestId = validTokenIds.first;
    double bestScore = -9999.0;

    for (final tokenId in validTokenIds) {
      final score = _evaluateMove(state, rules, tokenId, isHard: false);
      if (score > bestScore) {
        bestScore = score;
        bestId = tokenId;
      }
    }

    return bestId;
  }

  /// Hard AI: Thorough heuristic evaluation factoring danger, pursuit, and defense.
  String _chooseHard(
    GameState state,
    RulesEngine rules,
    List<String> validTokenIds,
  ) {
    String bestId = validTokenIds.first;
    double bestScore = -99999.0;

    for (final tokenId in validTokenIds) {
      final score = _evaluateMove(state, rules, tokenId, isHard: true);
      if (score > bestScore) {
        bestScore = score;
        bestId = tokenId;
      }
    }

    return bestId;
  }

  /// Heuristic evaluation for applying move to [tokenId].
  double _evaluateMove(
    GameState state,
    RulesEngine rules,
    String tokenId, {
    required bool isHard,
  }) {
    final token = state.tokens.firstWhere((t) => t.id == tokenId);
    final rollValue = state.currentRoll?.totalValue ?? 1;
    final geometry = rules.geometry;
    final activePlayer = state.activePlayer;

    double score = 0.0;

    // 1. Entering token from Kottam onto the board
    if (token.state == TokenState.inKottam && rollValue == 1) {
      final tokensInPlay = state
          .tokensForPlayer(state.activePlayerIndex)
          .where((t) => t.state == TokenState.onTrack)
          .length;

      score += (tokensInPlay < 2) ? 140.0 : 80.0;
      return score;
    }

    // Predict landing position
    final newSteps = token.stepsMoved + rollValue;
    final maxOuter = geometry.totalOuterCells;

    // 2. Reaching Pazham (Victory milestone)
    if (newSteps >= geometry.totalStepsToFinish &&
        (!rules.requireCaptureToEnterHome || activePlayer.hasCaptured)) {
      return 1000.0; // Ultimate priority!
    }

    // 3. Entering home stretch
    if (newSteps > maxOuter &&
        (!rules.requireCaptureToEnterHome || activePlayer.hasCaptured)) {
      score += 180.0 + (newSteps - maxOuter) * 15.0;
    }

    // 4. Movement on outer circuit
    if (newSteps <= maxOuter) {
      final entryCell = geometry.playerEntryCells[state.activePlayerIndex] ?? 0;
      final targetCell = (entryCell + (newSteps - 1)) % geometry.totalOuterCells;
      final isTargetSafe = geometry.isCellSafe(targetCell);

      // Check if target cell has an opponent to CAPTURE!
      for (final other in state.tokens) {
        if (other.playerIndex != state.activePlayerIndex &&
            other.state == TokenState.onTrack &&
            other.cellIndex == targetCell &&
            !isTargetSafe) {
          // HUGE BONUS FOR CAPTURE!
          score += 300.0;
          if (!activePlayer.hasCaptured) {
            score += 200.0; // Crucial capture to unlock homeward path!
          }
        }
      }

      // Safe square bonus
      if (isTargetSafe) {
        score += 90.0;
      }

      // Progress bonus
      score += rollValue * 5.0;

      if (isHard) {
        // Hard AI: Danger analysis
        // Is target cell within range of an opponent behind us?
        if (!isTargetSafe) {
          for (final opponentToken in state.tokens) {
            if (opponentToken.playerIndex != state.activePlayerIndex &&
                opponentToken.state == TokenState.onTrack) {
              final oppCell = opponentToken.cellIndex;
              final dist = (targetCell - oppCell + maxOuter) % maxOuter;
              // If opponent is within 1 to 6 steps behind us, risk of being captured!
              if (dist >= 1 && dist <= 6) {
                score -= 80.0;
              }
            }
          }
        }

        // Escape danger: If currently on unsafe cell within range of opponent
        if (token.state == TokenState.onTrack && !token.isSafe) {
          for (final opponentToken in state.tokens) {
            if (opponentToken.playerIndex != state.activePlayerIndex &&
                opponentToken.state == TokenState.onTrack) {
              final oppCell = opponentToken.cellIndex;
              final dist = (token.cellIndex - oppCell + maxOuter) % maxOuter;
              if (dist >= 1 && dist <= 6) {
                score += 110.0; // Great idea to move out of danger!
              }
            }
          }
        }
      }
    }

    return score;
  }
}
