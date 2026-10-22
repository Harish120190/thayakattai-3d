# DATABASE SCHEMA SPECIFICATION — THAYA NETRIK
## Cloud Firestore Scalable Data Model & Security Architecture

### 1. Collections Hierarchy

```
users/ {userId}
  ├── private_profile/ {userId}
  ├── friends/ {friendUserId}
  ├── invitations/ {invitationId}
  └── match_history/ {matchId}

game_rooms/ {roomId}
  └── events/ {eventId}

game_matches/ {matchId}
  ├── moves/ {moveId}
  └── snapshots/ {snapshotId}

leaderboards/ {periodId}
  └── rankings/ {userId}

reports/ {reportId}
```

---

### 2. Document Models

#### A. `users/{userId}`
```json
{
  "uid": "usr_948a7b6c",
  "username": "KarthikRaja",
  "displayName": "Karthik Raja",
  "avatarId": "warrior_brass",
  "rating": 1250,
  "matchesPlayed": 42,
  "matchesWon": 28,
  "winRate": 0.667,
  "isGuest": false,
  "createdAt": "2026-10-21T10:00:00Z",
  "lastActive": "2026-10-21T11:15:00Z"
}
```

#### B. `game_rooms/{roomId}`
```json
{
  "roomId": "RM_7B9A2F",
  "roomCode": "THAYA8",
  "isPrivate": true,
  "hostId": "usr_948a7b6c",
  "playerCount": 4,
  "tokensPerPlayer": 4,
  "rulesetId": "traditional_tamil",
  "status": "lobby", // "lobby", "in_game", "completed", "abandoned"
  "maxPlayers": 4,
  "players": [
    {
      "userId": "usr_948a7b6c",
      "playerIndex": 0,
      "displayName": "Karthik",
      "avatarId": "warrior_brass",
      "isReady": true,
      "isHost": true,
      "isAI": false
    }
  ],
  "createdAt": 1792671200000,
  "updatedAt": 1792671210000,
  "expiresAt": 1792678400000
}
```

#### C. `game_matches/{matchId}`
```json
{
  "matchId": "MTH_8829F",
  "roomId": "RM_7B9A2F",
  "playerCount": 4,
  "activePlayerIndex": 1,
  "turnPhase": "waitingForMove", // "waitingForRoll", "waitingForMove", "completed"
  "lastDiceOutcome": {
    "die1": 1,
    "die2": 0,
    "total": 1,
    "isBonus": true,
    "isThayam": true
  },
  "turnTimeRemaining": 28,
  "players": [
    {
      "id": "usr_948a7b6c",
      "name": "Karthik",
      "color": "maroon",
      "hasCaptured": true,
      "tokensAtHome": 0,
      "tokensInPlay": 3,
      "tokensFinished": 1
    }
  ],
  "tokens": [
    {
      "id": "t_0_1",
      "playerIndex": 0,
      "tokenIndex": 1,
      "state": "onTrack", // "inKottam", "onTrack", "onHomeStretch", "inPazham"
      "cellIndex": 14,
      "stepsMoved": 14,
      "isSafe": true
    }
  ],
  "rankings": [],
  "status": "active", // "active", "completed", "abandoned"
  "createdAt": 1792671220000,
  "updatedAt": 1792671245000
}
```

---

### 3. Firestore Security Rules Blueprint

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profile: public read, owner write
    match /users/{userId} {
      allow read: if true;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId
                    && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['rating', 'matchesWon']);
    }

    // Rooms: participants can read and write lobby states
    match /game_rooms/{roomId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }

    // Game match: verified players or server admin
    match /game_matches/{matchId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Reports: create only
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read, update, delete: if false;
    }
  }
}
```
