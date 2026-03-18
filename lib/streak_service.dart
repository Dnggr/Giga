import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'streak_model.dart';

class StreakService {
  static const String _startTimeKey = 'streak_start_time';
  static const String _historyKey = 'streak_history';
  static const String _isRunningKey = 'streak_is_running';
  final _uuid = const Uuid();

  // ── START a new streak
  Future<void> startStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startTimeKey, DateTime.now().toIso8601String());
    await prefs.setBool(_isRunningKey, true);
  }

  // ── CHECK if streak is running
  Future<bool> isStreakRunning() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isRunningKey) ?? false;
  }

  // ── LOAD streak start time
  Future<DateTime?> loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_startTimeKey);
    if (raw == null) return null;
    return DateTime.parse(raw);
  }

  // ── RELAPSE — save to history + reset timer
  Future<void> relapse({
    required String note,
    required String badgeName,
    required int daysReached,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // load existing history
    final history = await loadHistory();

    // get start time
    final String? rawStart = prefs.getString(_startTimeKey);
    final startTime = rawStart != null
        ? DateTime.parse(rawStart)
        : DateTime.now();

    // create new history entry
    final entry = StreakEntry(
      id: _uuid.v4(),
      startTime: startTime,
      endTime: DateTime.now(),
      note: note,
      badgeName: badgeName,
      daysReached: daysReached,
    );

    history.insert(0, entry); // newest first

    // save updated history
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encoded);

    // reset streak
    await prefs.setString(_startTimeKey, DateTime.now().toIso8601String());
    await prefs.setBool(_isRunningKey, false);
  }

  // ── LOAD all history entries
  Future<List<StreakEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_historyKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((item) => StreakEntry.fromJson(item)).toList();
  }

  // ── CLEAR all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── GET prefs (for direct access if needed)
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ── CALCULATE days elapsed from start time
  int getDaysElapsed(DateTime startTime) {
    return DateTime.now().difference(startTime).inDays;
  }

  // ── GET current badge based on days
  String getCurrentBadge(int days) {
    if (days >= 365) return 'Absolute Giga Chad';
    if (days >= 120) return 'Giga Chad';
    if (days >= 60) return 'Absolute Chad';
    if (days >= 45) return 'Chad';
    if (days >= 30) return 'Sigma';
    if (days >= 15) return 'Advanced';
    if (days >= 7) return 'Average';
    if (days >= 3) return 'Novice';
    if (days >= 1) return 'Noob';
    return 'Clown';
  }

  // ── GET badge image path
  String getBadgeImage(String badgeName) {
    switch (badgeName) {
      case 'Giga Chad':
        return 'assets/badges/giga_chad.png';
      case 'Absolute Chad':
        return 'assets/badges/absolute_chad.png';
      case 'Chad':
        return 'assets/badges/chad.png';
      case 'Sigma':
        return 'assets/badges/sigma.png';
      case 'Advanced':
        return 'assets/badges/advanced.png';
      case 'Average':
        return 'assets/badges/average.png';
      case 'Novice':
        return 'assets/badges/novice.png';
      case 'Noob':
        return 'assets/badges/noob.png';
      default:
        return 'assets/badges/clown.png';
    }
  }
}
