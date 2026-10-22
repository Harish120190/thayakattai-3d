/// Token placement states in the Thayakattai lifecycle.
enum TokenState {
  /// Token is waiting in player's starting sanctuary (Kottam)
  inKottam,

  /// Token has entered the main outer board circuit
  onTrack,

  /// Token has entered the homeward stretch toward the center
  onHomeStretch,

  /// Token has reached the central goal (Pazham / Mahameru)
  inPazham,
}

class TokenModel {
  final String id; // e.g. "p0_t0"
  final int playerIndex; // 0..7
  final int tokenIndex; // 0..3
  final TokenState state;
  final int cellIndex; // Index along outer circuit or home stretch step
  final int stepsMoved; // Total steps advanced since leaving Kottam
  final bool isSafe; // True if on a Malai / Safe square

  const TokenModel({
    required this.id,
    required this.playerIndex,
    required this.tokenIndex,
    this.state = TokenState.inKottam,
    this.cellIndex = -1,
    this.stepsMoved = 0,
    this.isSafe = true,
  });

  TokenModel copyWith({
    String? id,
    int? playerIndex,
    int? tokenIndex,
    TokenState? state,
    int? cellIndex,
    int? stepsMoved,
    bool? isSafe,
  }) {
    return TokenModel(
      id: id ?? this.id,
      playerIndex: playerIndex ?? this.playerIndex,
      tokenIndex: tokenIndex ?? this.tokenIndex,
      state: state ?? this.state,
      cellIndex: cellIndex ?? this.cellIndex,
      stepsMoved: stepsMoved ?? this.stepsMoved,
      isSafe: isSafe ?? this.isSafe,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerIndex': playerIndex,
        'tokenIndex': tokenIndex,
        'state': state.name,
        'cellIndex': cellIndex,
        'stepsMoved': stepsMoved,
        'isSafe': isSafe,
      };

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] as String,
      playerIndex: json['playerIndex'] as int,
      tokenIndex: json['tokenIndex'] as int,
      state: TokenState.values.byName(json['state'] as String),
      cellIndex: json['cellIndex'] as int,
      stepsMoved: json['stepsMoved'] as int,
      isSafe: json['isSafe'] as bool,
    );
  }

  @override
  String toString() =>
      'Token($id: ${state.name}, cell: $cellIndex, steps: $stepsMoved, safe: $isSafe)';
}
