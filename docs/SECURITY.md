# SECURITY & FAIR PLAY — THAYA NETRIK
## Protection Principles, Access Controls & Abuse Prevention

### 1. Fair Play Principles
In traditional board games, trust and integrity are foundational. Thaya Netrik implements multiple security layers:
- **Authoritative Dice Rolling**: In online multiplayer, dice roll outcomes are generated server-side or by the room host using cryptographically secure pseudo-random number generators (`Random.secure()`). Clients cannot falsify rolls.
- **Move Legality Verification**: Every proposed move is validated against the game engine before updating the state. Illegal token jumps or premature homeward entries without captures ("Vettu") are rejected.
- **State Idempotency**: Concurrency locks prevent double-tap or race-condition moves.
- **Turn Timeout Enforcement**: If an active player is disconnected or fails to move within the timer duration (default 30 seconds), the turn automatically advances or the player is safely skipped.

---

### 2. User Data Privacy
- Passwords are never stored in plain text or logged.
- User email addresses are kept private in secure subcollections.
- Public player queries only expose sanitized public profiles (Display Name, Avatar, Elo Rating, Matches Won).

---

### 3. Community Safety
- **Player Reporting**: Users can report inappropriate usernames or abusive conduct directly from match and profile screens.
- **Player Blocking**: Blocked users cannot send friend requests or join private rooms hosted by the blocker.
