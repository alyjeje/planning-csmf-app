import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    // TODO: Activer quand Firebase sera configuré
    /*
    // Demander les permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifications autorisées');
    }
    
    // Obtenir le token FCM
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
    
    // Écouter les changements de token
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      // TODO: Mettre à jour le token sur le serveur
    });
    
    // Configurer les notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(initializationSettings);
    
    // Écouter les messages en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Gérer les clics sur les notifications
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    */
    
    // Pour le moment, générer un token fictif pour les tests
    _fcmToken = 'test_token_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('Token de test généré: $_fcmToken');
  }

  /*
  void _handleForegroundMessage(RemoteMessage message) {
    print('Message reçu en foreground: ${message.notification?.title}');
    
    // Afficher une notification locale
    _showLocalNotification(
      title: message.notification?.title ?? 'CSMF',
      body: message.notification?.body ?? '',
    );
  }
  
  void _handleNotificationClick(RemoteMessage message) {
    print('Notification cliquée: ${message.data}');
    // TODO: Naviguer vers la bonne page selon le type de notification
  }
  
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'csmf_channel',
      'CSMF Notifications',
      channelDescription: 'Notifications du CSMF Planning',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
  */
  
  // Pour tester les notifications localement
  Future<void> showTestNotification() async {
    debugPrint('Test notification (Firebase non configuré)');
    // await _showLocalNotification(
    //   title: 'Test CSMF',
    //   body: 'Ceci est une notification de test',
    // );
  }
}
