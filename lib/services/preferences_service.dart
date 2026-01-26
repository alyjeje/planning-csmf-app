import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Service de préférences utilisant Hive CE (pure Dart)
/// Évite complètement le crash SharedPreferencesPlugin sur iPadOS 26.2
class PreferencesService extends ChangeNotifier {
  static const String _boxName = 'preferences';
  static const String _keySelectedSite = 'selected_site';
  static const String _keySubscribedActivities = 'subscribed_activities';
  static const String _keyNotifyAll = 'notify_all';
  static const String _keyFcmToken = 'fcm_token';

  Box? _box;
  bool _isInitialized = false;

  String _selectedSite = 'Bercy';
  List<String> _subscribedActivities = [];
  bool _notifyAll = true;
  String? _fcmToken;

  // Getters
  String get selectedSite => _selectedSite;
  List<String> get subscribedActivities => List.unmodifiable(_subscribedActivities);
  bool get notifyAll => _notifyAll;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      // Initialiser Hive pour Flutter
      await Hive.initFlutter();
      
      // Ouvrir la box de préférences
      _box = await Hive.openBox(_boxName);
      
      // Charger les valeurs sauvegardées
      _selectedSite = _box?.get(_keySelectedSite, defaultValue: 'Bercy') ?? 'Bercy';
      
      final savedActivities = _box?.get(_keySubscribedActivities);
      if (savedActivities != null && savedActivities is List) {
        _subscribedActivities = List<String>.from(savedActivities);
      }
      
      _notifyAll = _box?.get(_keyNotifyAll, defaultValue: true) ?? true;
      _fcmToken = _box?.get(_keyFcmToken);
      
      _isInitialized = true;
      debugPrint('PreferencesService initialized with Hive CE');
    } catch (e) {
      debugPrint('Failed to init Hive preferences: $e');
      _isInitialized = false;
    }
  }

  Future<void> setSelectedSite(String site) async {
    _selectedSite = site;
    await _box?.put(_keySelectedSite, site);
    notifyListeners();
  }

  Future<void> setNotifyAll(bool value) async {
    _notifyAll = value;
    await _box?.put(_keyNotifyAll, value);
    notifyListeners();
  }

  Future<void> toggleActivitySubscription(String activity) async {
    if (_subscribedActivities.contains(activity)) {
      _subscribedActivities.remove(activity);
    } else {
      _subscribedActivities.add(activity);
    }
    await _box?.put(_keySubscribedActivities, _subscribedActivities);
    notifyListeners();
  }

  Future<void> setSubscribedActivities(List<String> activities) async {
    _subscribedActivities = List<String>.from(activities);
    await _box?.put(_keySubscribedActivities, _subscribedActivities);
    notifyListeners();
  }

  bool isSubscribedTo(String activity) {
    if (_notifyAll) return true;
    return _subscribedActivities.contains(activity);
  }

  Future<void> setFcmToken(String token) async {
    _fcmToken = token;
    await _box?.put(_keyFcmToken, token);
  }

  Future<void> close() async {
    await _box?.close();
  }
}
