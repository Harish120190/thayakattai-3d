import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/game_state.dart';
import '../data/models/player.dart';
import '../features/game_engine/ai_player.dart';
import '../features/game_engine/dice_engine.dart';
import '../features/game_engine/rules_engine.dart';
import '../services/audio_service.dart';
import '../services/local_storage_service.dart';
import 'localization/app_localizations.dart';

// SharedPreferences instance holder
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main before runApp');
});

// Local Storage Service
final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// Audio Service
final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.watch(localStorageProvider);
  return AudioService(
    isSoundEnabled: () => storage.soundEnabled,
    isHapticsEnabled: () => storage.hapticsEnabled,
  );
});

// App Language Provider using Riverpod 3 Notifier
final languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return ref.watch(localStorageProvider).language;
  }

  void setLanguage(AppLanguage lang) {
    ref.read(localStorageProvider).language = lang;
    state = lang;
  }
}

// Active Game Engine Provider using Riverpod 3 Notifier
final gameControllerProvider =
    NotifierProvider<GameController, GameState?>(GameController.new);

class GameController extends Notifier<GameState?> {
  RulesEngine? _rules;
  Timer? _aiTimer;
  DateTime? _matchStartTime;

  @override
  GameState? build() {
    ref.onDispose(() {
      _aiTimer?.cancel();
    });
    return null;
  }

  RulesEngine? get currentRules => _rules;

  void startNewGame({
    required int playerCount,
    required List<PlayerModel> players,
    int tokensPerPlayer = 4,
    bool requireCapture = true,
  }) {
    _aiTimer?.cancel();
    _rules = RulesEngine.forPlayerCount(
      playerCount,
      requireCaptureToEnterHome: requireCapture,
    );
    _matchStartTime = DateTime.now();

    final initialState = _rules!.createInitialMatch(
      matchId: 'match_${DateTime.now().millisecondsSinceEpoch}',
      players: players,
      tokensPerPlayer: tokensPerPlayer,
    );

    state = initialState;

    // Check if initial active player is AI
    _checkAndTriggerAI();
  }

  void rollDice() {
    final current = state;
    if (current == null || _rules == null) return;
    if (current.turnPhase != TurnPhase.waitingForRoll) return;

    final audio = ref.read(audioServiceProvider);
    audio.playDiceRoll();

    final outcome = DiceRollOutcome.roll();
    final nextState = _rules!.processDiceRoll(current, outcome);
    state = nextState;

    if (nextState.turnPhase == TurnPhase.waitingForMove) {
      _checkAndTriggerAI();
    } else if (nextState.turnPhase == TurnPhase.waitingForRoll) {
      _checkAndTriggerAI();
    }
  }

  void selectToken(String tokenId) {
    final current = state;
    if (current == null || _rules == null) return;
    if (current.turnPhase != TurnPhase.waitingForMove) return;
    if (!current.validMovableTokenIds.contains(tokenId)) return;

    final audio = ref.read(audioServiceProvider);
    audio.playTokenMove();

    final nextState = _rules!.applyMove(current, tokenId);

    if (nextState.lastEventMessage.contains('CAPTURED')) {
      audio.playCapture();
    }

    if (nextState.isOver) {
      audio.playVictory();
      _recordMatchStats(nextState);
    }

    state = nextState;
    _checkAndTriggerAI();
  }

  void _checkAndTriggerAI() {
    final current = state;
    if (current == null || _rules == null || current.isOver) return;

    final activePlayer = current.activePlayer;
    if (!activePlayer.isAI) return;

    _aiTimer?.cancel();
    _aiTimer = Timer(const Duration(milliseconds: 700), () {
      final s = state;
      if (s == null || s.isOver) return;

      if (s.turnPhase == TurnPhase.waitingForRoll) {
        rollDice();
      } else if (s.turnPhase == TurnPhase.waitingForMove &&
          s.validMovableTokenIds.isNotEmpty) {
        final ai = AIPlayer(difficulty: activePlayer.aiDifficulty);
        final chosenToken =
            ai.chooseMove(s, _rules!, s.validMovableTokenIds);
        selectToken(chosenToken);
      }
    });
  }

  void _recordMatchStats(GameState finalState) {
    final storage = ref.read(localStorageProvider);
    final duration =
        DateTime.now().difference(_matchStartTime ?? DateTime.now());
    final isHumanWon = finalState.winners.isNotEmpty &&
        !finalState.players[finalState.winners.first].isAI;

    storage.recordMatchResult(won: isHumanWon);
    storage.addMatchToHistory({
      'matchId': finalState.matchId,
      'playerCount': finalState.playerCount,
      'winner': finalState.players[finalState.winners.first].name,
      'isHumanWon': isHumanWon,
      'durationSeconds': duration.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
