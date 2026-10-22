import 'package:flutter_test/flutter_test.dart';
import 'package:thaya_netrik/data/models/game_state.dart';
import 'package:thaya_netrik/data/models/player.dart';
import 'package:thaya_netrik/data/models/token.dart';
import 'package:thaya_netrik/features/game_engine/ai_player.dart';
import 'package:thaya_netrik/features/game_engine/board_geometry.dart';
import 'package:thaya_netrik/features/game_engine/dice_engine.dart';
import 'package:thaya_netrik/features/game_engine/rules_engine.dart';

void main() {
  group('Thayakattai Dice Engine Tests', () {
    test('Throws produce authentic traditional outcomes', () {
      final roll1 = DiceRollOutcome.fromFaces(1, 0);
      expect(roll1.totalValue, 1);
      expect(roll1.isThayam, isTrue);
      expect(roll1.isBonus, isTrue);
      expect(roll1.traditionalName, 'Thayam');

      final roll1b = DiceRollOutcome.fromFaces(0, 1);
      expect(roll1b.totalValue, 1);
      expect(roll1b.isThayam, isTrue);

      final roll12 = DiceRollOutcome.fromFaces(0, 0);
      expect(roll12.totalValue, 12);
      expect(roll12.isBonus, isTrue);
      expect(roll12.traditionalName, 'Panirendu (12)');

      final roll2 = DiceRollOutcome.fromFaces(1, 1);
      expect(roll2.totalValue, 2);
      expect(roll2.isBonus, isFalse);

      final roll5 = DiceRollOutcome.fromFaces(2, 3);
      expect(roll5.totalValue, 5);
      expect(roll5.isBonus, isTrue); // 5 gives bonus roll

      final roll6 = DiceRollOutcome.fromFaces(3, 3);
      expect(roll6.totalValue, 6);
      expect(roll6.isBonus, isTrue); // 6 gives bonus roll
    });
  });

  group('Board Geometry Tests (2, 4, 6, 8 Players)', () {
    test('2-player board geometry is symmetrical', () {
      final geo = BoardGeometry.forPlayerCount(2);
      expect(geo.playerCount, 2);
      expect(geo.totalOuterCells, 24);
      expect(geo.playerEntryCells[0], 0);
      expect(geo.playerEntryCells[1], 12); // Opposite side
      expect(geo.isCellSafe(0), isTrue);
      expect(geo.isCellSafe(12), isTrue);
    });

    test('4-player board geometry has 4 entries', () {
      final geo = BoardGeometry.forPlayerCount(4);
      expect(geo.playerCount, 4);
      expect(geo.totalOuterCells, 24);
      expect(geo.playerEntryCells[0], 0);
      expect(geo.playerEntryCells[1], 6);
      expect(geo.playerEntryCells[2], 12);
      expect(geo.playerEntryCells[3], 18);
    });

    test('6-player hexagonal mandala geometry', () {
      final geo = BoardGeometry.forPlayerCount(6);
      expect(geo.playerCount, 6);
      expect(geo.totalOuterCells, 36);
      expect(geo.playerEntryCells.length, 6);
      expect(geo.playerEntryCells[5], 30);
    });

    test('8-player octagonal mandala geometry', () {
      final geo = BoardGeometry.forPlayerCount(8);
      expect(geo.playerCount, 8);
      expect(geo.totalOuterCells, 48);
      expect(geo.playerEntryCells.length, 8);
      expect(geo.playerEntryCells[7], 42);
    });
  });

  group('Rules Engine & Game Flow Tests', () {
    late RulesEngine rules;
    late List<PlayerModel> players;

    setUp(() {
      rules = RulesEngine.forPlayerCount(4);
      players = [
        const PlayerModel(id: 'p0', name: 'Player 1', colorHex: '#8B0000', playerIndex: 0),
        const PlayerModel(id: 'p1', name: 'Player 2', colorHex: '#D4AF37', playerIndex: 1),
        const PlayerModel(id: 'p2', name: 'Player 3', colorHex: '#10B981', playerIndex: 2),
        const PlayerModel(id: 'p3', name: 'Player 4', colorHex: '#3B82F6', playerIndex: 3),
      ];
    });

    test('Initial game state correctly places all tokens in Kottam', () {
      final state = rules.createInitialMatch(matchId: 'test_1', players: players, tokensPerPlayer: 4);
      expect(state.tokens.length, 16);
      expect(state.tokens.every((t) => t.state == TokenState.inKottam), isTrue);
      expect(state.activePlayerIndex, 0);
      expect(state.turnPhase, TurnPhase.waitingForRoll);
    });

    test('Non-Thayam roll with all tokens in Kottam passes turn', () {
      var state = rules.createInitialMatch(matchId: 'test_2', players: players, tokensPerPlayer: 4);
      final roll2 = DiceRollOutcome.fromFaces(1, 1); // 2

      state = rules.processDiceRoll(state, roll2);
      // Turn passes to player 1 because 2 cannot enter pieces from Kottam
      expect(state.activePlayerIndex, 1);
      expect(state.turnPhase, TurnPhase.waitingForRoll);
    });

    test('Thayam (1) allows entering token onto starting safe square', () {
      var state = rules.createInitialMatch(matchId: 'test_3', players: players, tokensPerPlayer: 4);
      final thayam = DiceRollOutcome.fromFaces(1, 0); // Thayam (1)

      state = rules.processDiceRoll(state, thayam);
      expect(state.turnPhase, TurnPhase.waitingForMove);
      expect(state.validMovableTokenIds.length, 4); // All 4 tokens can enter

      // Apply move to first token
      state = rules.applyMove(state, 'p0_t0');
      final movedToken = state.tokens.firstWhere((t) => t.id == 'p0_t0');
      expect(movedToken.state, TokenState.onTrack);
      expect(movedToken.cellIndex, 0); // Player 0 entry cell
      expect(movedToken.isSafe, isTrue); // Starting cell 0 is Malai (safe)

      // Rolling Thayam grants an extra turn!
      expect(state.activePlayerIndex, 0);
      expect(state.turnPhase, TurnPhase.waitingForRoll);
    });

    test('Capturing an opponent piece on unsafe cell knocks it back to Kottam and awards extra turn', () {
      var state = rules.createInitialMatch(matchId: 'test_capture', players: players, tokensPerPlayer: 4);

      // Setup: Place P1's token on cell 2 (not safe!)
      final updatedTokens = List<TokenModel>.from(state.tokens);
      final p1TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p1_t0');
      updatedTokens[p1TokenIdx] = updatedTokens[p1TokenIdx].copyWith(
        state: TokenState.onTrack,
        cellIndex: 2,
        stepsMoved: 5,
        isSafe: false,
      );

      // Place P0's token on cell 0
      final p0TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p0_t0');
      updatedTokens[p0TokenIdx] = updatedTokens[p0TokenIdx].copyWith(
        state: TokenState.onTrack,
        cellIndex: 0,
        stepsMoved: 1,
        isSafe: true,
      );

      state = state.copyWith(tokens: updatedTokens);

      // P0 rolls 2 (1+1)
      final roll2 = DiceRollOutcome.fromFaces(1, 1);
      state = rules.processDiceRoll(state, roll2);
      expect(state.validMovableTokenIds.contains('p0_t0'), isTrue);

      // Apply move: P0 lands on cell 2!
      state = rules.applyMove(state, 'p0_t0');

      // P1's piece should now be captured and back in Kottam
      final capturedP1Token = state.tokens.firstWhere((t) => t.id == 'p1_t0');
      expect(capturedP1Token.state, TokenState.inKottam);
      expect(capturedP1Token.cellIndex, -1);

      // P0 now has hasCaptured = true!
      expect(state.players[0].hasCaptured, isTrue);

      // P0 gets an extra turn because of the capture!
      expect(state.activePlayerIndex, 0);
      expect(state.turnPhase, TurnPhase.waitingForRoll);
    });

    test('Tokens on Safe Squares (Malai) cannot be captured', () {
      var state = rules.createInitialMatch(matchId: 'test_safe', players: players, tokensPerPlayer: 4);

      // Place P1's token on cell 6 (Safe Square!)
      final updatedTokens = List<TokenModel>.from(state.tokens);
      final p1TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p1_t0');
      updatedTokens[p1TokenIdx] = updatedTokens[p1TokenIdx].copyWith(
        state: TokenState.onTrack,
        cellIndex: 6,
        stepsMoved: 1,
        isSafe: true,
      );

      // Place P0's token on cell 2 (needs 4 to reach 6)
      final p0TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p0_t0');
      updatedTokens[p0TokenIdx] = updatedTokens[p0TokenIdx].copyWith(
        state: TokenState.onTrack,
        cellIndex: 2,
        stepsMoved: 3,
        isSafe: false,
      );

      state = state.copyWith(tokens: updatedTokens);

      // P0 rolls 4 (2+2)
      final roll4 = DiceRollOutcome.fromFaces(2, 2);
      state = rules.processDiceRoll(state, roll4);
      state = rules.applyMove(state, 'p0_t0');

      // Both tokens should safely coexist on cell 6!
      final p1Token = state.tokens.firstWhere((t) => t.id == 'p1_t0');
      final p0Token = state.tokens.firstWhere((t) => t.id == 'p0_t0');
      expect(p1Token.state, TokenState.onTrack);
      expect(p1Token.cellIndex, 6);
      expect(p0Token.cellIndex, 6);
      expect(p0Token.isSafe, isTrue);
    });

    test('Token requires a capture before it can enter homeward lane', () {
      var state = rules.createInitialMatch(matchId: 'test_vettu_req', players: players, tokensPerPlayer: 4);

      // P0 token at step 23 of 24, has NOT captured yet
      final updatedTokens = List<TokenModel>.from(state.tokens);
      final p0TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p0_t0');
      updatedTokens[p0TokenIdx] = updatedTokens[p0TokenIdx].copyWith(
        state: TokenState.onTrack,
        cellIndex: 22,
        stepsMoved: 23,
        isSafe: false,
      );

      state = state.copyWith(tokens: updatedTokens);
      expect(state.players[0].hasCaptured, isFalse);

      // Roll 3
      final roll3 = DiceRollOutcome.fromFaces(1, 2);
      state = rules.processDiceRoll(state, roll3);
      state = rules.applyMove(state, 'p0_t0');

      final movedToken = state.tokens.firstWhere((t) => t.id == 'p0_t0');
      // Token MUST remain on outer track because player has not captured!
      expect(movedToken.state, TokenState.onTrack);
    });

    test('Token with capture enters home stretch and reaches Pazham', () {
      var state = rules.createInitialMatch(matchId: 'test_pazham', players: players, tokensPerPlayer: 1);

      // Set P0 hasCaptured = true, and token at home stretch step 3
      final updatedPlayers = List<PlayerModel>.from(state.players);
      updatedPlayers[0] = updatedPlayers[0].copyWith(hasCaptured: true);

      final updatedTokens = List<TokenModel>.from(state.tokens);
      final p0TokenIdx = updatedTokens.indexWhere((t) => t.id == 'p0_t0');
      updatedTokens[p0TokenIdx] = updatedTokens[p0TokenIdx].copyWith(
        state: TokenState.onHomeStretch,
        cellIndex: 3,
        stepsMoved: 27,
        isSafe: true,
      );

      state = state.copyWith(tokens: updatedTokens, players: updatedPlayers);

      // Roll 1 (Thayam) to reach Pazham!
      final thayam = DiceRollOutcome.fromFaces(1, 0);
      state = rules.processDiceRoll(state, thayam);
      state = rules.applyMove(state, 'p0_t0');

      final finishedToken = state.tokens.firstWhere((t) => t.id == 'p0_t0');
      expect(finishedToken.state, TokenState.inPazham);
      expect(state.winners.contains(0), isTrue);
    });
  });

  group('AI Player Decision Tests', () {
    test('Easy, Medium, and Hard AI select legal moves without crashing', () {
      final rules = RulesEngine.forPlayerCount(4);
      final players = [
        const PlayerModel(id: 'ai0', name: 'AI 1', colorHex: '#8B0000', playerIndex: 0, isAI: true, aiDifficulty: AIDifficulty.easy),
        const PlayerModel(id: 'ai1', name: 'AI 2', colorHex: '#D4AF37', playerIndex: 1, isAI: true, aiDifficulty: AIDifficulty.medium),
        const PlayerModel(id: 'ai2', name: 'AI 3', colorHex: '#10B981', playerIndex: 2, isAI: true, aiDifficulty: AIDifficulty.hard),
        const PlayerModel(id: 'p3', name: 'Human', colorHex: '#3B82F6', playerIndex: 3),
      ];

      var state = rules.createInitialMatch(matchId: 'test_ai', players: players, tokensPerPlayer: 4);
      final thayam = DiceRollOutcome.fromFaces(1, 0);
      state = rules.processDiceRoll(state, thayam);

      final aiEasy = AIPlayer(difficulty: AIDifficulty.easy);
      final moveEasy = aiEasy.chooseMove(state, rules, state.validMovableTokenIds);
      expect(state.validMovableTokenIds.contains(moveEasy), isTrue);

      final aiMedium = AIPlayer(difficulty: AIDifficulty.medium);
      final moveMedium = aiMedium.chooseMove(state, rules, state.validMovableTokenIds);
      expect(state.validMovableTokenIds.contains(moveMedium), isTrue);

      final aiHard = AIPlayer(difficulty: AIDifficulty.hard);
      final moveHard = aiHard.chooseMove(state, rules, state.validMovableTokenIds);
      expect(state.validMovableTokenIds.contains(moveHard), isTrue);
    });
  });
}
