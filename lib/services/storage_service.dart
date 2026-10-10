import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_stats_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Nickname
  String getNickname() {
    return _prefs.getString(AppConstants.keyPlayerNickname) ?? 'Racer_${(1000 + DateTime.now().millisecond % 9000)}';
  }

  Future<void> setNickname(String nickname) async {
    await _prefs.setString(AppConstants.keyPlayerNickname, nickname);
  }

  // Car Id
  String getCarId() {
    return _prefs.getString(AppConstants.keyPlayerCarId) ?? 'sun_dazer';
  }

  Future<void> setCarId(String carId) async {
    await _prefs.setString(AppConstants.keyPlayerCarId, carId);
  }

  // Car Color
  int getCarColor() {
    return _prefs.getInt(AppConstants.keyPlayerCarColor) ?? 0xFF00E5FF;
  }

  Future<void> setCarColor(int colorValue) async {
    await _prefs.setInt(AppConstants.keyPlayerCarColor, colorValue);
  }

  // Avatar Index
  int getAvatarIndex() {
    return _prefs.getInt(AppConstants.keyPlayerAvatarIndex) ?? 0;
  }

  Future<void> setAvatarIndex(int index) async {
    await _prefs.setInt(AppConstants.keyPlayerAvatarIndex, index);
  }

  // Audio Settings
  bool getSoundEnabled() {
    return _prefs.getBool(AppConstants.keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keySoundEnabled, enabled);
  }

  bool getHapticsEnabled() {
    return _prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyHapticsEnabled, enabled);
  }

  // User Stats
  UserStatsModel getUserStats() {
    return UserStatsModel(
      racesPlayed: _prefs.getInt(AppConstants.keyRacesPlayed) ?? 0,
      racesWon: _prefs.getInt(AppConstants.keyRacesWon) ?? 0,
      bestWpm: _prefs.getDouble(AppConstants.keyBestWpm) ?? 0.0,
      totalWordsTyped: _prefs.getInt(AppConstants.keyTotalWords) ?? 0,
      averageAccuracy: _prefs.getDouble(AppConstants.keyAvgAccuracy) ?? 100.0,
    );
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    await _prefs.setInt(AppConstants.keyRacesPlayed, stats.racesPlayed);
    await _prefs.setInt(AppConstants.keyRacesWon, stats.racesWon);
    await _prefs.setDouble(AppConstants.keyBestWpm, stats.bestWpm);
    await _prefs.setInt(AppConstants.keyTotalWords, stats.totalWordsTyped);
    await _prefs.setDouble(AppConstants.keyAvgAccuracy, stats.averageAccuracy);
  }
}
