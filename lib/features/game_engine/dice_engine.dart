import 'dart:math';

/// Representation of an authentic Thayakattai dice throw.
class DiceRollOutcome {
  final int die1; // 0, 1, 2, or 3
  final int die2; // 0, 1, 2, or 3
  final int totalValue;
  final bool isThayam;
  final bool isBonus;
  final String traditionalName;
  final String tamilName;

  const DiceRollOutcome({
    required this.die1,
    required this.die2,
    required this.totalValue,
    required this.isThayam,
    required this.isBonus,
    required this.traditionalName,
    required this.tamilName,
  });

  /// Calculates outcome from two individual dice faces (0, 1, 2, 3).
  factory DiceRollOutcome.fromFaces(int d1, int d2) {
    assert(d1 >= 0 && d1 <= 3, 'Die 1 must be between 0 and 3');
    assert(d2 >= 0 && d2 <= 3, 'Die 2 must be between 0 and 3');

    // Traditional Tamil combinations:
    // (0,0) -> 12 (Panirendu)
    // (1,0) or (0,1) -> 1 (Thayam)
    // Otherwise sum of faces (1..6)
    int total;
    if (d1 == 0 && d2 == 0) {
      total = 12;
    } else if ((d1 == 1 && d2 == 0) || (d1 == 0 && d2 == 1)) {
      total = 1;
    } else {
      total = d1 + d2;
    }

    final isThayam = (total == 1);
    // In traditional Thayakattai: 1, 5, 6, and 12 award extra turns!
    final isBonus = (total == 1 || total == 5 || total == 6 || total == 12);

    String nameEn;
    String nameTa;
    switch (total) {
      case 1:
        nameEn = 'Thayam';
        nameTa = 'தாயம்';
        break;
      case 2:
        nameEn = 'Irandu (2)';
        nameTa = 'இரண்டு';
        break;
      case 3:
        nameEn = 'Moondru (3)';
        nameTa = 'மூன்று';
        break;
      case 4:
        nameEn = 'Naangu (4)';
        nameTa = 'நான்கு';
        break;
      case 5:
        nameEn = 'Ainthu (5)';
        nameTa = 'ஐந்து';
        break;
      case 6:
        nameEn = 'Aaru (6)';
        nameTa = 'ஆறு';
        break;
      case 12:
        nameEn = 'Panirendu (12)';
        nameTa = 'பன்னிரண்டு';
        break;
      default:
        nameEn = '$total';
        nameTa = '$total';
    }

    return DiceRollOutcome(
      die1: d1,
      die2: d2,
      totalValue: total,
      isThayam: isThayam,
      isBonus: isBonus,
      traditionalName: nameEn,
      tamilName: nameTa,
    );
  }

  /// Generate a random throw using cryptographically secure or pseudo-random generator.
  static DiceRollOutcome roll({Random? random}) {
    final rng = random ?? Random.secure();
    final d1 = rng.nextInt(4); // 0, 1, 2, 3
    final d2 = rng.nextInt(4); // 0, 1, 2, 3
    return DiceRollOutcome.fromFaces(d1, d2);
  }

  Map<String, dynamic> toJson() => {
        'die1': die1,
        'die2': die2,
        'totalValue': totalValue,
        'isThayam': isThayam,
        'isBonus': isBonus,
        'traditionalName': traditionalName,
        'tamilName': tamilName,
      };

  factory DiceRollOutcome.fromJson(Map<String, dynamic> json) {
    return DiceRollOutcome(
      die1: json['die1'] as int,
      die2: json['die2'] as int,
      totalValue: json['totalValue'] as int,
      isThayam: json['isThayam'] as bool,
      isBonus: json['isBonus'] as bool,
      traditionalName: json['traditionalName'] as String,
      tamilName: json['tamilName'] as String,
    );
  }

  @override
  String toString() => '$traditionalName ($die1, $die2)';
}
