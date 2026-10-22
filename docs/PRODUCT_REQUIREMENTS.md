# PRODUCT REQUIREMENTS — THAYA NETRIK
## Traditional Indian Multiplayer Gaming Application

### 1. Vision & Identity
- **Product Name**: Thaya Netrik (தாய நேத்ரிக்)
- **Brand**: Netrik.AI
- **Tagline**: Ancient Tamil Strategy, Modern Multiplayer Thrills
- **Mission**: Bring the rich cultural heritage and strategic gameplay of Thayakattai to players worldwide across mobile, tablet, and web with real-time multiplayer, smart AI opponents, rich traditional art, and competitive rankings.

---

### 2. Supported Platforms & Environments
- **Flutter Web**: Production release deployed to static web / CDN / Firebase Hosting. Fully responsive across desktop browsers and mobile web.
- **Android**: Release AAB & APK targeting modern Android devices (phones and tablets).
- **iOS**: Complete Xcode / iOS configuration for iPhone and iPad.
- **Form Factors**: Adaptive layouts for mobile phones (portrait), tablets (landscape/portrait adaptive), and desktop browsers (wide centered board).

---

### 3. Core Features & Functional Requirements

#### A. Game Modes
1. **Local Pass-and-Play**:
   - Single device shared among 2, 4, 6, or 8 human players.
   - Distinct player banners, turn alert indicators, and tactile dice throw interaction.
   - Configurable turn timer and persistent autosave.
2. **Play Against AI**:
   - 1 human vs AI, or mixed human/AI slots.
   - 3 difficulty levels:
     - **Easy**: Casual beginner moves with basic advancement.
     - **Medium**: Opportunistic moves prioritizing piece entry and immediate captures.
     - **Hard**: Minimax/heuristic evaluation assessing risk, safety, home stretch pacing, and capture defense.
3. **Online Private Multiplayer**:
   - 6-character room codes.
   - Shareable join links.
   - Real-time room lobby with ready indicators, avatar selection, and host controls.
4. **Online Public Multiplayer**:
   - Matchmaking queue filtered by player count (2, 4, 6, 8).
   - Public lobby room browser.
5. **Private Friends Match**:
   - Friend list with online status.
   - Direct game invitations with push/in-app alert.

#### B. Player Counts
- **2 Players**: Fast-paced head-to-head match.
- **4 Players**: Traditional 4-arm cross mandala.
- **6 Players**: 6-arm hexagonal mandala board.
- **8 Players**: 8-arm octagonal mandala board.

#### C. Audio & Visual Experience
- Royal Indian theme: Deep Indigo, Crimson, Golden Ochre, Ivory, and Emerald.
- Traditional Kolam ornamental patterns and brass dice aesthetics.
- Authentic sound effects for dice roll, piece entry, capture ("Vettu"), and victory celebration.
- Smooth piece movement animations and celebration confetti.
- Full Tamil and English bilingual localization.

#### D. Security & Data Integrity
- Server-authoritative move validation.
- Concurrency locks preventing conflicting turns.
- Guest authentication with seamless upgrade to email/password or Google identity.
- Elo-based rating and verified match statistics.
