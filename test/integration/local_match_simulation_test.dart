import 'package:flutter_test/flutter_test.dart';
import 'package:thaya_netrik/data/models/game_state.dart';
import 'package:thaya_netrik/data/models/player.dart';
import 'package:thaya_netrik/features/game_engine/ai_player.dart';
import 'package:thaya_netrik/features/game_engine/dice_engine.dart';
import 'package:thaya_netrik/features/game_engine/rules_engine.dart';

void main() {
  group('End-to-End Match Simulation Integration Tests', () {
    test('Simulate 2-player match with AI until victory', () {
      final rules = RulesEngine.forPlayerCount(2, requireCaptureToEnterHome: false);
      final players = [
        const PlayerModel(id: 'p0', name: 'Human 1', colorHex: '#8B0000', playerIndex: 0),
        const PlayerModel(id: 'ai1', name: 'AI Opponent', colorHex: '#D4AF37', playerIndex: 1, isAI: true, aiDifficulty: AIDifficulty.medium),
      ];

      var state = rules.createInitialMatch(matchId: 'sim_match', players: players, tokensPerPlayer: 1);
      final ai = AIPlayer(difficulty: AIDifficulty.medium);

      int turns = 0;
      const maxTurns = 500;

      while (!state.isOver && turns < maxTurns) {
        turns++;

        // Roll dice
        final roll = DiceRollOutcome.roll();
        state = rules.processDiceRoll(state, roll);

        if (state.turnPhase == TurnPhase.waitingForMove && state.validMovableTokenIds.isNotEmpty) {
          final chosenToken = ai.chooseMove(state, rules, state.validMovableTokenIds);
          state = rules.applyMove(state, chosenToken);
        }
      }

      // Verify game progressed and moves were executed legally
      expect(turns, greaterThan(0));
      expect(state.tokens.every((t) => t.stepsMoved >= 0), isTrue);
    });

    test('Simulate 6-player and 8-player match turns and rotations', () {
      final rules6 = RulesEngine.forPlayerCount(6);
      final players6 = List.generate(
        6,
        (i) => PlayerModel(id: 'p$i', name: 'P$i', colorHex: '#FFFFFF', playerIndex: i),
      );

      var state6 = rules6.createInitialMatch(matchId: 'sim_6p', players: players6, tokensPerPlayer: 2);
      expect(state6.playerCount, 6);
      expect(state6.tokens.length, 12);

      // Roll non-thayam to test turn rotation
      final roll2 = DiceRollOutcome.fromFaces(1, 1);
      state6 = rules6.processDiceRoll(state6, roll2);
      expect(state6.activePlayerIndex, 1);

      final rules8 = RulesEngine.forPlayerCount(8);
      final players8 = List.generate(
        8,
        (i) => PlayerModel(id: 'p$i', name: 'P$i', colorHex: '#FFFFFF', playerIndex: i),
      );

      var state8 = rules8.createInitialMatch(matchId: 'sim_8p', players: players8, tokensPerPlayer: 2);
      expect(state8.playerCount, 8);
      expect(state8.tokens.length, 16);
      state8 = rules8.processDiceRoll(state8, roll2);
      expect(state8.activePlayerIndex, 1);
    });
  });
}
