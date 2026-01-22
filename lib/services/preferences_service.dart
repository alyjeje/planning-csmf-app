import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  static const String _keySelectedSite = 'selected_site';
  static const String _keySubscribedActivities = 'subscribed_activities';
  static const String _keyNotifyAll = 'notify_all';
  static const String _keyFcmToken = 'fcm_token';

  String _selectedSite = 'Bercy';
  List<String> _subscribedActivities = [];
  bool _notifyAll = true;
  String? _fcmToken;

  // Getters
  String get selectedSite => _selectedSite;
  List<String> get subscribedActivities => _subscribedActivities;
  bool get notifyAll => _notifyAll;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _loadPreferences();
    } catch (e) {
      // Si SharedPreferences échoue (ex: iPadOS beta), continuer avec les valeurs par défaut
      debugPrint('SharedPreferences init failed: $e');
      _isInitialized = false;
    }
  }

  void _loadPreferences() {
    if (_prefs == null) return;
    _selectedSite = _prefs!.getString(_keySelectedSite) ?? 'Bercy';
    _subscribedActivities = _prefs!.getStringList(_keySubscribedActivities) ?? [];
    _notifyAll = _prefs!.getBool(_keyNotifyAll) ?? true;
    _fcmToken = _prefs!.getString(_keyFcmToken);
    notifyListeners();
  }

  Future<void> setSelectedSite(String site) async {
    _selectedSite = site;
    if (_prefs != null) {
      await _prefs!.setString(_keySelectedSite, site);
    }
    notifyListeners();
  }

  Future<void> setNotifyAll(bool value) async {
    _notifyAll = value;
    if (_prefs != null) {
      await _prefs!.setBool(_keyNotifyAll, value);
    }
    notifyListeners();
  }

  Future<void> toggleActivitySubscription(String activity) async {
    if (_subscribedActivities.contains(activity)) {
      _subscribedActivities.remove(activity);
    } else {
      _subscribedActivities.add(activity);
    }
    if (_prefs != null) {
      await _prefs!.setStringList(_keySubscribedActivities, _subscribedActivities);
    }
    notifyListeners();
  }

  Future<void> setSubscribedActivities(List<String> activities) async {
    _subscribedActivities = activities;
    if (_prefs != null) {
      await _prefs!.setStringList(_keySubscribedActivities, activities);
    }
    notifyListeners();
  }

  bool isSubscribedTo(String activity) {
    if (_notifyAll) return true;
    return _subscribedActivities.contains(activity);
  }

  Future<void> setFcmToken(String token) async {
    _fcmToken = token;
    if (_prefs != null) {
      await _prefs!.setString(_keyFcmToken, token);
    }
  }
}
