enum AIDifficulty {
  easy,
  medium,
  hard,
}

class PlayerModel {
  final String id;
  final String name;
  final String colorHex;
  final int playerIndex; // 0..7
  final bool isAI;
  final AIDifficulty aiDifficulty;
  final bool hasCaptured; // Crucial traditional condition to unlock home stretch!
  final int? rank; // 1 for 1st, 2 for 2nd, etc.
  final String avatarId;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.playerIndex,
    this.isAI = false,
    this.aiDifficulty = AIDifficulty.medium,
    this.hasCaptured = false,
    this.rank,
    this.avatarId = 'avatar_1',
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? playerIndex,
    bool? isAI,
    AIDifficulty? aiDifficulty,
    bool? hasCaptured,
    int? rank,
    String? avatarId,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      playerIndex: playerIndex ?? this.playerIndex,
      isAI: isAI ?? this.isAI,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      hasCaptured: hasCaptured ?? this.hasCaptured,
      rank: rank ?? this.rank,
      avatarId: avatarId ?? this.avatarId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'playerIndex': playerIndex,
        'isAI': isAI,
        'aiDifficulty': aiDifficulty.name,
        'hasCaptured': hasCaptured,
        'rank': rank,
        'avatarId': avatarId,
      };

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String,
      playerIndex: json['playerIndex'] as int,
      isAI: json['isAI'] as bool,
      aiDifficulty: AIDifficulty.values.byName(json['aiDifficulty'] as String),
      hasCaptured: json['hasCaptured'] as bool,
      rank: json['rank'] as int?,
      avatarId: json['avatarId'] as String? ?? 'avatar_1',
    );
  }

  @override
  String toString() => 'Player($name, idx: $playerIndex, AI: $isAI, rank: $rank)';
}
