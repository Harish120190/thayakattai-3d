import 'player.dart';
import 'token.dart';
import '../../features/game_engine/dice_engine.dart';

enum TurnPhase {
  waitingForRoll,
  waitingForMove,
  turnFinished,
  matchFinished,
}

class GameState {
  final String matchId;
  final int playerCount;
  final int tokensPerPlayer;
  final List<PlayerModel> players;
  final List<TokenModel> tokens;
  final int activePlayerIndex;
  final TurnPhase turnPhase;
  final DiceRollOutcome? currentRoll;
  final int consecutiveRolls;
  final bool hasPendingBonusRoll;
  final List<String> validMovableTokenIds;
  final String lastEventMessage;
  final String lastEventTamilMessage;
  final List<int> winners; // Player indices in finishing order
  final bool isOver;
  final int turnTimeRemaining; // Seconds remaining in active turn

  const GameState({
    required this.matchId,
    required this.playerCount,
    required this.tokensPerPlayer,
    required this.players,
    required this.tokens,
    this.activePlayerIndex = 0,
    this.turnPhase = TurnPhase.waitingForRoll,
    this.currentRoll,
    this.consecutiveRolls = 0,
    this.hasPendingBonusRoll = false,
    this.validMovableTokenIds = const [],
    this.lastEventMessage = 'Game started. Roll the Thayakattai!',
    this.lastEventTamilMessage = 'ஆட்டம் தொடங்கியது. தாயக்கட்டையை உருட்டுங்கள்!',
    this.winners = const [],
    this.isOver = false,
    this.turnTimeRemaining = 30,
  });

  PlayerModel get activePlayer => players[activePlayerIndex];

  List<TokenModel> tokensForPlayer(int playerIndex) {
    return tokens.where((t) => t.playerIndex == playerIndex).toList();
  }

  GameState copyWith({
    String? matchId,
    int? playerCount,
    int? tokensPerPlayer,
    List<PlayerModel>? players,
    List<TokenModel>? tokens,
    int? activePlayerIndex,
    TurnPhase? turnPhase,
    DiceRollOutcome? currentRoll,
    bool clearCurrentRoll = false,
    int? consecutiveRolls,
    bool? hasPendingBonusRoll,
    List<String>? validMovableTokenIds,
    String? lastEventMessage,
    String? lastEventTamilMessage,
    List<int>? winners,
    bool? isOver,
    int? turnTimeRemaining,
  }) {
    return GameState(
      matchId: matchId ?? this.matchId,
      playerCount: playerCount ?? this.playerCount,
      tokensPerPlayer: tokensPerPlayer ?? this.tokensPerPlayer,
      players: players ?? this.players,
      tokens: tokens ?? this.tokens,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      turnPhase: turnPhase ?? this.turnPhase,
      currentRoll: clearCurrentRoll ? null : (currentRoll ?? this.currentRoll),
      consecutiveRolls: consecutiveRolls ?? this.consecutiveRolls,
      hasPendingBonusRoll: hasPendingBonusRoll ?? this.hasPendingBonusRoll,
      validMovableTokenIds: validMovableTokenIds ?? this.validMovableTokenIds,
      lastEventMessage: lastEventMessage ?? this.lastEventMessage,
      lastEventTamilMessage:
          lastEventTamilMessage ?? this.lastEventTamilMessage,
      winners: winners ?? this.winners,
      isOver: isOver ?? this.isOver,
      turnTimeRemaining: turnTimeRemaining ?? this.turnTimeRemaining,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'playerCount': playerCount,
        'tokensPerPlayer': tokensPerPlayer,
        'players': players.map((p) => p.toJson()).toList(),
        'tokens': tokens.map((t) => t.toJson()).toList(),
        'activePlayerIndex': activePlayerIndex,
        'turnPhase': turnPhase.name,
        'currentRoll': currentRoll?.toJson(),
        'consecutiveRolls': consecutiveRolls,
        'hasPendingBonusRoll': hasPendingBonusRoll,
        'validMovableTokenIds': validMovableTokenIds,
        'lastEventMessage': lastEventMessage,
        'lastEventTamilMessage': lastEventTamilMessage,
        'winners': winners,
        'isOver': isOver,
        'turnTimeRemaining': turnTimeRemaining,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      matchId: json['matchId'] as String,
      playerCount: json['playerCount'] as int,
      tokensPerPlayer: json['tokensPerPlayer'] as int,
      players: (json['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      tokens: (json['tokens'] as List)
          .map((t) => TokenModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      activePlayerIndex: json['activePlayerIndex'] as int,
      turnPhase: TurnPhase.values.byName(json['turnPhase'] as String),
      currentRoll: json['currentRoll'] != null
          ? DiceRollOutcome.fromJson(json['currentRoll'] as Map<String, dynamic>)
          : null,
      consecutiveRolls: json['consecutiveRolls'] as int? ?? 0,
      hasPendingBonusRoll: json['hasPendingBonusRoll'] as bool? ?? false,
      validMovableTokenIds: (json['validMovableTokenIds'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastEventMessage: json['lastEventMessage'] as String? ?? '',
      lastEventTamilMessage: json['lastEventTamilMessage'] as String? ?? '',
      winners: (json['winners'] as List?)?.map((e) => e as int).toList() ??
          const [],
      isOver: json['isOver'] as bool? ?? false,
      turnTimeRemaining: json['turnTimeRemaining'] as int? ?? 30,
    );
  }
}
