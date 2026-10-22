import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/localization/app_localizations.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyAvatarId = 'avatar_id';
  static const _keyRating = 'user_rating';
  static const _keyMatchesPlayed = 'matches_played';
  static const _keyMatchesWon = 'matches_won';
  static const _keyLanguage = 'app_language';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyHapticsEnabled = 'haptics_enabled';
  static const _keySavedMatch = 'saved_match_state';
  static const _keyMatchHistory = 'match_history_list';

  // User Profile
  String get userId => _prefs.getString(_keyUserId) ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
  set userId(String value) => _prefs.setString(_keyUserId, value);

  String get username => _prefs.getString(_keyUsername) ?? 'வீரன் (Warrior)';
  set username(String value) => _prefs.setString(_keyUsername, value);

  String get avatarId => _prefs.getString(_keyAvatarId) ?? 'avatar_1';
  set avatarId(String value) => _prefs.setString(_keyAvatarId, value);

  int get rating => _prefs.getInt(_keyRating) ?? 1200;
  set rating(int value) => _prefs.setInt(_keyRating, value);

  int get matchesPlayed => _prefs.getInt(_keyMatchesPlayed) ?? 0;
  set matchesPlayed(int value) => _prefs.setInt(_keyMatchesPlayed, value);

  int get matchesWon => _prefs.getInt(_keyMatchesWon) ?? 0;
  set matchesWon(int value) => _prefs.setInt(_keyMatchesWon, value);

  void recordMatchResult({required bool won, int ratingChange = 15}) {
    matchesPlayed = matchesPlayed + 1;
    if (won) {
      matchesWon = matchesWon + 1;
      rating = rating + ratingChange;
    } else {
      rating = (rating - ratingChange).clamp(800, 3000);
    }
  }

  // Preferences
  AppLanguage get language {
    final langStr = _prefs.getString(_keyLanguage);
    if (langStr == 'tamil') return AppLanguage.tamil;
    return AppLanguage.english;
  }

  set language(AppLanguage lang) {
    _prefs.setString(_keyLanguage, lang.name);
  }

  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  set soundEnabled(bool value) => _prefs.setBool(_keySoundEnabled, value);

  bool get hapticsEnabled => _prefs.getBool(_keyHapticsEnabled) ?? true;
  set hapticsEnabled(bool value) => _prefs.setBool(_keyHapticsEnabled, value);

  // Saved Active Match (Autosave / Resume)
  String? get savedMatchJson => _prefs.getString(_keySavedMatch);
  set savedMatchJson(String? jsonStr) {
    if (jsonStr == null) {
      _prefs.remove(_keySavedMatch);
    } else {
      _prefs.setString(_keySavedMatch, jsonStr);
    }
  }

  // Match History
  List<Map<String, dynamic>> get matchHistory {
    final raw = _prefs.getString(_keyMatchHistory);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  void addMatchToHistory(Map<String, dynamic> record) {
    final history = matchHistory;
    history.insert(0, record);
    if (history.length > 50) history.removeLast(); // Keep latest 50
    _prefs.setString(_keyMatchHistory, jsonEncode(history));
  }
}
