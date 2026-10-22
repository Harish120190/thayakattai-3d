# TESTING GUIDE & TEST SUITE — THAYA NETRIK

### 1. Test Architecture
Thaya Netrik features a comprehensive multi-layered test suite:
- **Unit Tests (`test/unit/`)**:
  - `dice_engine_test.dart`: Validates probability distribution, bonus roll triggers (1, 5, 6, 12), and pairing rules.
  - `rules_engine_test.dart`: Validates piece entry on Thayam, step movement, safe square protection, captures ("Vettu"), Vettu requirement for homeward stretch, and win conditions.
  - `player_counts_test.dart`: Validates 2, 4, 6, and 8-player board geometries, cell indices, and turn cycling.
  - `ai_player_test.dart`: Validates AI decision-making across Easy, Medium, and Hard strategies.
- **Widget Tests (`test/widget/`)**:
  - Main app smoke test, theme toggling, localization rendering.
  - Dice throw animation widget.
  - Board interactive tap tests.
- **Integration Tests (`test/integration/`)**:
  - End-to-end local match simulation from first roll to victory podium.

### 2. Executing Automated Tests
Run all unit and widget tests:
```powershell
flutter test
```

Generate coverage report:
```powershell
flutter test --coverage
```
