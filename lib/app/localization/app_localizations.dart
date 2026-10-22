enum AppLanguage {
  english,
  tamil,
}

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  static final Map<String, Map<AppLanguage, String>> _strings = {
    // Brand & App
    'app_title': {
      AppLanguage.english: 'Thaya Netrik',
      AppLanguage.tamil: 'தாய நேத்ரிக்',
    },
    'tagline': {
      AppLanguage.english: 'Indian Traditional Board Gaming',
      AppLanguage.tamil: 'பாரம்பரிய இந்திய பலகை விளையாட்டு',
    },

    // Modes & Actions
    'play_now': {
      AppLanguage.english: 'Play Now',
      AppLanguage.tamil: 'இப்போதே விளையாடு',
    },
    'play_with_friends': {
      AppLanguage.english: 'Play with Friends',
      AppLanguage.tamil: 'நண்பர்களுடன் விளையாடு',
    },
    'local_multiplayer': {
      AppLanguage.english: 'Local Pass & Play',
      AppLanguage.tamil: 'நேரடி விளையாட்டு (Pass & Play)',
    },
    'play_ai': {
      AppLanguage.english: 'Play Against AI',
      AppLanguage.tamil: 'கணினியுடன் விளையாடு (AI)',
    },
    'create_room': {
      AppLanguage.english: 'Create Room',
      AppLanguage.tamil: 'அறை உருவாக்கு',
    },
    'join_room': {
      AppLanguage.english: 'Join Room',
      AppLanguage.tamil: 'அறையில் சேர்',
    },
    'leaderboard': {
      AppLanguage.english: 'Leaderboard',
      AppLanguage.tamil: 'மதிப்பெண் பட்டியல்',
    },
    'match_history': {
      AppLanguage.english: 'Match History',
      AppLanguage.tamil: 'ஆட்ட வரலாறு',
    },
    'friends': {
      AppLanguage.english: 'Friends',
      AppLanguage.tamil: 'நண்பர்கள்',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.tamil: 'அமைப்புகள்',
    },
    'tutorial': {
      AppLanguage.english: 'How to Play',
      AppLanguage.tamil: 'விளையாடும் முறை',
    },

    // Player Counts
    'select_players': {
      AppLanguage.english: 'Select Player Count',
      AppLanguage.tamil: 'ஆட்டக்காரர்கள் எண்ணிக்கை',
    },
    'players_2': {
      AppLanguage.english: '2 Players',
      AppLanguage.tamil: '2 ஆட்டக்காரர்கள்',
    },
    'players_4': {
      AppLanguage.english: '4 Players',
      AppLanguage.tamil: '4 ஆட்டக்காரர்கள்',
    },
    'players_6': {
      AppLanguage.english: '6 Players',
      AppLanguage.tamil: '6 ஆட்டக்காரர்கள்',
    },
    'players_8': {
      AppLanguage.english: '8 Players',
      AppLanguage.tamil: '8 ஆட்டக்காரர்கள்',
    },

    // In Game
    'roll_dice': {
      AppLanguage.english: 'Roll Thayakattai',
      AppLanguage.tamil: 'தாயக்கட்டையை உருட்டு',
    },
    'your_turn': {
      AppLanguage.english: 'Your Turn',
      AppLanguage.tamil: 'உங்கள் முறை',
    },
    'waiting_for_roll': {
      AppLanguage.english: 'Rolling dice...',
      AppLanguage.tamil: 'உருட்டப்படுகிறது...',
    },
    'select_piece': {
      AppLanguage.english: 'Tap a piece to move',
      AppLanguage.tamil: 'நகர்த்த வேண்டிய காயைத் தொடவும்',
    },
    'extra_turn': {
      AppLanguage.english: 'Extra Turn Granted!',
      AppLanguage.tamil: 'கூடுதல் வாய்ப்பு கிடைத்தது!',
    },
    'captured': {
      AppLanguage.english: 'Piece Captured (Vettu)!',
      AppLanguage.tamil: 'காய் வெட்டப்பட்டது!',
    },
    'pazham_reached': {
      AppLanguage.english: 'Token Reached Pazham!',
      AppLanguage.tamil: 'காய் பழமானது!',
    },
    'game_over': {
      AppLanguage.english: 'Game Over',
      AppLanguage.tamil: 'ஆட்டம் முடிந்தது',
    },
    'winner': {
      AppLanguage.english: 'Winner',
      AppLanguage.tamil: 'வெற்றியாளர்',
    },
    'play_again': {
      AppLanguage.english: 'Play Again',
      AppLanguage.tamil: 'மீண்டும் விளையாடு',
    },
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.tamil: 'முகப்பு',
    },

    // Room Lobby
    'room_code': {
      AppLanguage.english: 'Room Code',
      AppLanguage.tamil: 'அறை குறியீடு',
    },
    'ready': {
      AppLanguage.english: 'Ready',
      AppLanguage.tamil: 'தயார்',
    },
    'not_ready': {
      AppLanguage.english: 'Not Ready',
      AppLanguage.tamil: 'தயாராகவில்லை',
    },
    'start_game': {
      AppLanguage.english: 'Start Game',
      AppLanguage.tamil: 'ஆட்டத்தைத் தொடங்கு',
    },
    'share_code': {
      AppLanguage.english: 'Share Room Code',
      AppLanguage.tamil: 'குறியீட்டைப் பகிர்',
    },
    'copied': {
      AppLanguage.english: 'Room code copied to clipboard!',
      AppLanguage.tamil: 'அறை குறியீடு நகலெடுக்கப்பட்டது!',
    },

    // Settings
    'language': {
      AppLanguage.english: 'Language / மொழி',
      AppLanguage.tamil: 'மொழி / Language',
    },
    'sound_effects': {
      AppLanguage.english: 'Sound Effects',
      AppLanguage.tamil: 'ஒலி விளைவுகள்',
    },
    'haptics': {
      AppLanguage.english: 'Vibration & Haptics',
      AppLanguage.tamil: 'அதிர்வு விளைவு',
    },
    'rules_variation': {
      AppLanguage.english: 'Require Capture to Enter Home',
      AppLanguage.tamil: 'பழப்பாதைக்குள் நுழைய வெட்டு கட்டாயம்',
    },
  };

  String tr(String key) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[language] ?? entry[AppLanguage.english] ?? key;
  }
}
