import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/token.dart';
import 'board_geometry.dart';
import 'dice_engine.dart';

class RulesEngine {
  final BoardGeometry geometry;
  final bool requireCaptureToEnterHome; // Traditional Vettu requirement
  final bool requireExactRollForPazham; // Exact count to reach center

  RulesEngine({
    required this.geometry,
    this.requireCaptureToEnterHome = true,
    this.requireExactRollForPazham = true,
  });

  /// Factory constructor configured for a specific player count.
  factory RulesEngine.forPlayerCount(
    int playerCount, {
    bool requireCaptureToEnterHome = true,
    bool requireExactRollForPazham = true,
  }) {
    return RulesEngine(
      geometry: BoardGeometry.forPlayerCount(playerCount),
      requireCaptureToEnterHome: requireCaptureToEnterHome,
      requireExactRollForPazham: requireExactRollForPazham,
    );
  }

  /// Creates a fresh initial GameState for a match.
  GameState createInitialMatch({
    required String matchId,
    required List<PlayerModel> players,
    int tokensPerPlayer = 4,
  }) {
    final tokens = <TokenModel>[];
    for (var p = 0; p < players.length; p++) {
      for (var t = 0; t < tokensPerPlayer; t++) {
        tokens.add(TokenModel(
          id: 'p${p}_t$t',
          playerIndex: p,
          tokenIndex: t,
          state: TokenState.inKottam,
          cellIndex: -1,
          stepsMoved: 0,
          isSafe: true,
        ));
      }
    }

    return GameState(
      matchId: matchId,
      playerCount: players.length,
      tokensPerPlayer: tokensPerPlayer,
      players: players,
      tokens: tokens,
      activePlayerIndex: 0,
      turnPhase: TurnPhase.waitingForRoll,
      validMovableTokenIds: const [],
      lastEventMessage: '${players[0].name}\'s turn. Roll the Thayakattai!',
      lastEventTamilMessage:
          '${players[0].name} அவர்களின் முறை. தாயக்கட்டையை உருட்டுங்கள்!',
    );
  }

  /// Computes all tokens of the active player that can legally move with [rollValue].
  List<String> getLegalMoves(GameState state, int rollValue) {
    if (state.isOver) return [];
    final activePlayer = state.activePlayer;
    final playerTokens = state.tokensForPlayer(state.activePlayerIndex);
    final legalTokenIds = <String>[];

    for (final token in playerTokens) {
      if (canTokenMove(state, token, rollValue, activePlayer)) {
        legalTokenIds.add(token.id);
      }
    }

    return legalTokenIds;
  }

  /// Determines whether a single token can legally move.
  bool canTokenMove(
    GameState state,
    TokenModel token,
    int rollValue,
    PlayerModel player,
  ) {
    // 1. Tokens already finished in Pazham cannot move
    if (token.state == TokenState.inPazham) {
      return false;
    }

    // 2. Token in Kottam can ONLY enter if roll is Thayam (1)
    if (token.state == TokenState.inKottam) {
      return rollValue == 1;
    }

    // 3. Token on outer track
    if (token.state == TokenState.onTrack) {
      final newSteps = token.stepsMoved + rollValue;
      final maxOuterSteps = geometry.totalOuterCells;

      if (newSteps <= maxOuterSteps) {
        // Still on outer track - always legal
        return true;
      } else {
        // Trying to enter home stretch
        if (requireCaptureToEnterHome && !player.hasCaptured) {
          // Cannot enter home stretch without a capture!
          // In traditional rules, token continues looping the outer track!
          return true;
        }

        // Has captured or capture not required -> heading to Pazham
        final homeSteps = newSteps - maxOuterSteps;
        if (homeSteps <= geometry.homeStretchLength) {
          return true;
        } else {
          // Overshooting beyond Pazham
          return !requireExactRollForPazham;
        }
      }
    }

    // 4. Token already on home stretch
    if (token.state == TokenState.onHomeStretch) {
      final currentHomeStep = token.cellIndex; // 1..homeStretchLength
      final newHomeStep = currentHomeStep + rollValue;

      if (newHomeStep <= geometry.homeStretchLength) {
        return true;
      } else {
        // Overshooting beyond Pazham
        return !requireExactRollForPazham;
      }
    }

    return false;
  }

  /// Executes a dice roll for the active player and determines next turn phase.
  GameState processDiceRoll(GameState state, DiceRollOutcome roll) {
    assert(state.turnPhase == TurnPhase.waitingForRoll);

    final legalMoves = getLegalMoves(state, roll.totalValue);
    final activePlayer = state.activePlayer;

    final rollDescEn =
        '${activePlayer.name} rolled ${roll.traditionalName}! (${roll.die1}, ${roll.die2})';
    final rollDescTa =
        '${activePlayer.name} ${roll.tamilName} உருட்டினார்! (${roll.die1}, ${roll.die2})';

    if (legalMoves.isEmpty) {
      // No legal moves
      if (roll.isBonus && state.consecutiveRolls < 3) {
        // Bonus roll grants another try even if no moves possible with this one
        return state.copyWith(
          currentRoll: roll,
          consecutiveRolls: state.consecutiveRolls + 1,
          validMovableTokenIds: const [],
          turnPhase: TurnPhase.waitingForRoll,
          lastEventMessage:
              '$rollDescEn - No moves possible, but bonus roll granted!',
          lastEventTamilMessage:
              '$rollDescTa - நகர்த்த வாய்ப்பில்லை, கூடுதல் உருட்டல் கிடைத்தது!',
        );
      } else {
        // Turn ends, pass to next player
        return _advanceTurn(state.copyWith(
          currentRoll: roll,
          validMovableTokenIds: const [],
          lastEventMessage:
              '$rollDescEn - No legal moves. Turn passed to next player.',
          lastEventTamilMessage:
              '$rollDescTa - நகர்த்த வழியில்லை. அடுத்தவருக்கு வாய்ப்பு.',
        ));
      }
    }

    // Waiting for player to select which piece to move
    return state.copyWith(
      currentRoll: roll,
      turnPhase: TurnPhase.waitingForMove,
      validMovableTokenIds: legalMoves,
      lastEventMessage: rollDescEn,
      lastEventTamilMessage: rollDescTa,
    );
  }

  /// Applies the selected move to [tokenId].
  GameState applyMove(GameState state, String tokenId) {
    assert(state.turnPhase == TurnPhase.waitingForMove);
    assert(state.currentRoll != null);
    assert(state.validMovableTokenIds.contains(tokenId));

    final roll = state.currentRoll!;
    final rollValue = roll.totalValue;
    final token = state.tokens.firstWhere((t) => t.id == tokenId);
    final activePlayer = state.activePlayer;
    final updatedTokens = List<TokenModel>.from(state.tokens);
    var updatedPlayers = List<PlayerModel>.from(state.players);

    bool madeCapture = false;
    TokenModel movedToken;
    String moveDescEn = '';
    String moveDescTa = '';

    // CASE 1: Entering token from Kottam onto the board
    if (token.state == TokenState.inKottam && rollValue == 1) {
      final entryCell = geometry.playerEntryCells[state.activePlayerIndex] ?? 0;
      movedToken = token.copyWith(
        state: TokenState.onTrack,
        cellIndex: entryCell,
        stepsMoved: 1,
        isSafe: geometry.isCellSafe(entryCell),
      );
      moveDescEn =
          '${activePlayer.name} entered a token onto the board at safe square $entryCell!';
      moveDescTa =
          '${activePlayer.name} ஒரு காயை மலை கட்டத்தில் களமிறக்கினார்!';
    }
    // CASE 2: Moving token on outer track
    else if (token.state == TokenState.onTrack) {
      final newSteps = token.stepsMoved + rollValue;
      final maxOuterSteps = geometry.totalOuterCells;

      if (newSteps <= maxOuterSteps) {
        // Standard movement on outer circuit
        final entryCell =
            geometry.playerEntryCells[state.activePlayerIndex] ?? 0;
        final newCellIndex =
            (entryCell + (newSteps - 1)) % geometry.totalOuterCells;
        final isSafe = geometry.isCellSafe(newCellIndex);

        movedToken = token.copyWith(
          cellIndex: newCellIndex,
          stepsMoved: newSteps,
          isSafe: isSafe,
        );
        moveDescEn = '${activePlayer.name} advanced to cell $newCellIndex.';
        moveDescTa = '${activePlayer.name} $newCellIndex-ம் கட்டத்திற்கு நகர்ந்தார்.';
      } else {
        // Past the outer track
        if (requireCaptureToEnterHome && !activePlayer.hasCaptured) {
          // Loop around outer track because player has not captured yet!
          final entryCell =
              geometry.playerEntryCells[state.activePlayerIndex] ?? 0;
          final newCellIndex =
              (entryCell + (newSteps - 1)) % geometry.totalOuterCells;
          final isSafe = geometry.isCellSafe(newCellIndex);

          movedToken = token.copyWith(
            cellIndex: newCellIndex,
            stepsMoved: newSteps,
            isSafe: isSafe,
          );
          moveDescEn =
              '${activePlayer.name} continued outer circuit (Capture required for home entry!).';
          moveDescTa =
              '${activePlayer.name} வட்டப்பாதையில் தொடர்கிறார் (வெட்டு தேவை!).';
        } else {
          // Entering home stretch
          final homeSteps = newSteps - maxOuterSteps;
          if (homeSteps >= geometry.homeStretchLength) {
            // Reached central Pazham!
            movedToken = token.copyWith(
              state: TokenState.inPazham,
              cellIndex: 999,
              stepsMoved: geometry.totalStepsToFinish,
              isSafe: true,
            );
            moveDescEn = '🌟 ${activePlayer.name}\'s token reached PAZHAM (Home)!';
            moveDescTa = '🌟 ${activePlayer.name} காய் பழமானது!';
          } else {
            movedToken = token.copyWith(
              state: TokenState.onHomeStretch,
              cellIndex: homeSteps,
              stepsMoved: newSteps,
              isSafe: true,
            );
            moveDescEn =
                '${activePlayer.name} entered the homeward lane (Step $homeSteps)!';
            moveDescTa =
                '${activePlayer.name} பழப்பாதையில் ($homeSteps) நுழைந்தார்!';
          }
        }
      }
    }
    // CASE 3: Moving token already on home stretch
    else if (token.state == TokenState.onHomeStretch) {
      final newHomeStep = token.cellIndex + rollValue;
      if (newHomeStep >= geometry.homeStretchLength) {
        movedToken = token.copyWith(
          state: TokenState.inPazham,
          cellIndex: 999,
          stepsMoved: geometry.totalStepsToFinish,
          isSafe: true,
        );
        moveDescEn = '🌟 ${activePlayer.name}\'s token reached PAZHAM (Home)!';
        moveDescTa = '🌟 ${activePlayer.name} காய் பழமானது!';
      } else {
        movedToken = token.copyWith(
          cellIndex: newHomeStep,
          stepsMoved: token.stepsMoved + rollValue,
          isSafe: true,
        );
        moveDescEn =
            '${activePlayer.name} advanced along homeward lane to step $newHomeStep.';
        moveDescTa =
            '${activePlayer.name} பழப்பாதையில் $newHomeStep அடி நகர்ந்தார்.';
      }
    } else {
      movedToken = token;
    }

    // Check for CAPTURES ("Vettu") on outer circuit non-safe cells
    if (movedToken.state == TokenState.onTrack && !movedToken.isSafe) {
      for (var i = 0; i < updatedTokens.length; i++) {
        final other = updatedTokens[i];
        if (other.id != movedToken.id &&
            other.playerIndex != state.activePlayerIndex &&
            other.state == TokenState.onTrack &&
            other.cellIndex == movedToken.cellIndex) {
          // CAPTURE! Knock opponent token back to Kottam
          updatedTokens[i] = other.copyWith(
            state: TokenState.inKottam,
            cellIndex: -1,
            stepsMoved: 0,
            isSafe: true,
          );
          madeCapture = true;
          final opponentName = state.players[other.playerIndex].name;
          moveDescEn += ' ⚔️ CAPTURED $opponentName\'s piece!';
          moveDescTa += ' ⚔️ $opponentName காயை வெட்டினார்!';
        }
      }
    }

    // Replace moved token in list
    final tokenIdx = updatedTokens.indexWhere((t) => t.id == tokenId);
    updatedTokens[tokenIdx] = movedToken;

    // Update player's capture status if capture was made
    if (madeCapture) {
      updatedPlayers[state.activePlayerIndex] =
          activePlayer.copyWith(hasCaptured: true);
    }

    // Check if active player has now finished all tokens
    final playerTokens = updatedTokens
        .where((t) => t.playerIndex == state.activePlayerIndex)
        .toList();
    final allPazham =
        playerTokens.every((t) => t.state == TokenState.inPazham);

    var winners = List<int>.from(state.winners);
    if (allPazham && !winners.contains(state.activePlayerIndex)) {
      winners.add(state.activePlayerIndex);
      final rank = winners.length;
      updatedPlayers[state.activePlayerIndex] =
          updatedPlayers[state.activePlayerIndex].copyWith(rank: rank);
      moveDescEn += ' 🏆 ${activePlayer.name} finished in Rank $rank!';
      moveDescTa += ' 🏆 ${activePlayer.name} $rank-ம் இடம் பெற்றார்!';
    }

    // Check if match is over (when all but 1 player have finished, or 1st place in 2-player)
    final isMatchOver = (winners.length >= state.playerCount - 1);

    // Determine if player gets another turn:
    // Bonus roll (1, 5, 6, 12) OR Made a Capture ("Vettu")!
    final getsExtraTurn = (roll.isBonus || madeCapture);

    if (isMatchOver) {
      return state.copyWith(
        tokens: updatedTokens,
        players: updatedPlayers,
        turnPhase: TurnPhase.matchFinished,
        winners: winners,
        isOver: true,
        lastEventMessage: '🎉 Match Finished! ${state.players[winners.first].name} WINS!',
        lastEventTamilMessage:
            '🎉 ஆட்டம் நிறைவுற்றது! ${state.players[winners.first].name} வெற்றி பெற்றார்!',
      );
    }

    if (getsExtraTurn && !allPazham) {
      // Active player rolls again
      return state.copyWith(
        tokens: updatedTokens,
        players: updatedPlayers,
        turnPhase: TurnPhase.waitingForRoll,
        clearCurrentRoll: true,
        consecutiveRolls: state.consecutiveRolls + 1,
        validMovableTokenIds: const [],
        winners: winners,
        lastEventMessage: '$moveDescEn Extra turn granted! Roll again.',
        lastEventTamilMessage:
            '$moveDescTa கூடுதல் வாய்ப்பு கிடைத்தது! மீண்டும் உருட்டுங்கள்.',
      );
    } else {
      // Pass turn to next active player
      return _advanceTurn(state.copyWith(
        tokens: updatedTokens,
        players: updatedPlayers,
        clearCurrentRoll: true,
        consecutiveRolls: 0,
        validMovableTokenIds: const [],
        winners: winners,
        lastEventMessage: moveDescEn,
        lastEventTamilMessage: moveDescTa,
      ));
    }
  }

  /// Advances turn to the next player who has not yet finished all tokens.
  GameState _advanceTurn(GameState state) {
    var nextIndex = (state.activePlayerIndex + 1) % state.playerCount;
    var attempts = 0;

    // Skip players who have already finished all their tokens
    while (state.winners.contains(nextIndex) && attempts < state.playerCount) {
      nextIndex = (nextIndex + 1) % state.playerCount;
      attempts++;
    }

    final nextPlayer = state.players[nextIndex];
    return state.copyWith(
      activePlayerIndex: nextIndex,
      turnPhase: TurnPhase.waitingForRoll,
      clearCurrentRoll: true,
      consecutiveRolls: 0,
      validMovableTokenIds: const [],
      turnTimeRemaining: 30,
      lastEventMessage: '${state.lastEventMessage} -> ${nextPlayer.name}\'s turn.',
      lastEventTamilMessage:
          '${state.lastEventTamilMessage} -> ${nextPlayer.name} அவர்களின் முறை.',
    );
  }
}
