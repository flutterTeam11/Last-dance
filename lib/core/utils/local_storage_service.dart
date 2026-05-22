import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _isLoggedInKey = 'is_logged_in';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setLoggedIn(bool value) async {
    await _ensurePrefs();
    await _prefs!.setBool(_isLoggedInKey, value);
  }

  Future<bool> getIsLoggedIn() async {
    await _ensurePrefs();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearAll() async {
    await _ensurePrefs();
    await _prefs!.remove(_isLoggedInKey);
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
