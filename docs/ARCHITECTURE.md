# ARCHITECTURE SPECIFICATION — THAYA NETRIK
## Clean Architecture & Modular System Design

### 1. High-Level Architecture Overview

Thaya Netrik is engineered following Clean Architecture principles with feature-first folder organization and the Repository pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                       Presentation Layer                    │
│   (Widgets, Screens, Animations, Localization, Riverpod)    │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                         Domain Layer                        │
│   (Game Engine, Rule Validator, AI Agent, Use Cases)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                         Data Layer                          │
│   (Repositories, Data Sources: Cloud Firestore / Local)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    External Services / Backend              │
│   (Firebase Auth, Firestore, Cloud Functions, LocalStorage) │
└─────────────────────────────────────────────────────────────┘
```

---

### 2. Feature-First Folder Organization

```
lib/
├── app/
│   ├── app.dart              # Main MaterialApp & theme wiring
│   ├── routes.dart           # Route definitions & navigator
│   ├── theme/
│   │   ├── app_colors.dart   # Royal Indian color palette
│   │   └── app_theme.dart    # ThemeData configurations
│   └── localization/
│       └── app_localizations.dart # English & Tamil translations
├── core/
│   ├── constants/
│   │   ├── game_constants.dart
│   │   └── board_constants.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── utils/
│   │   ├── haptics_helper.dart
│   │   └── room_code_generator.dart
│   └── widgets/
│       ├── netrik_button.dart
│       ├── kolam_background.dart
│       ├── dice_throw_widget.dart
│       └── glass_panel.dart
├── data/
│   ├── models/
│   │   ├── game_state.dart
│   │   ├── player.dart
│   │   ├── token.dart
│   │   ├── room.dart
│   │   └── user_profile.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── game_repository.dart
│       └── friends_repository.dart
├── features/
│   ├── authentication/
│   ├── onboarding/
│   ├── home/
│   ├── game_board/
│   ├── game_engine/
│   │   ├── board_geometry.dart
│   │   ├── rules_engine.dart
│   │   ├── dice_engine.dart
│   │   └── ai_player.dart
│   ├── game_lobby/
│   ├── game_mode_selection/
│   ├── game_results/
│   ├── friends/
│   ├── leaderboard/
│   ├── match_history/
│   ├── profiles/
│   ├── settings/
│   └── tutorial/
└── services/
    ├── audio_service.dart
    ├── local_storage_service.dart
    └── firebase_service.dart
```

---

### 3. Game Engine Layer (Pure Domain)
- **Deterministic & Independently Testable**: The game engine does not depend on Flutter UI elements, allowing 100% test coverage in Dart unit tests.
- **Board Geometry**: Generates symmetric coordinate rings, safe cell indexes, and homeward pathways for 2, 4, 6, and 8 player setups.
- **Turn State Machine**:
  - `waitingForRoll`: Active player must cast Thayakattai.
  - `rollCompleted`: Valid moves calculated for active player.
  - `waitingForMove`: Player selects a token to advance. If no legal moves exist, turn advances automatically.
  - `moveExecuted`: Piece animation, capture checks, bonus turn evaluation, victory check.
  - `matchCompleted`: Final rankings declared.

---

### 4. Multiplayer & Synchronization Layer
- **Authoritative Validation**: In online matches, the host or Cloud Function verifies every throw outcome and movement legality.
- **Dual Mode Repositories**:
  - `OfflineGameRepository`: Manages in-memory and SharedPreferences local matches.
  - `CloudFirestoreGameRepository`: Synchronizes live match state via Firestore snapshot streams with optimistic UI updates.
