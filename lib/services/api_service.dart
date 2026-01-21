import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';

class ApiService {
  static const String baseUrl = 'https://planning-csmf.azurewebsites.net/api';
  
  Future<Planning> getPlanning({String? semaine, String site = 'Bercy'}) async {
    String url = '$baseUrl/planning?site=$site';
    if (semaine != null) {
      url += '&semaine=$semaine';
    }
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return Planning.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement du planning');
    }
  }

  Future<Planning> getCurrentPlanning({String site = 'Bercy'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/planning/current?site=$site'),
    );
    
    if (response.statusCode == 200) {
      return Planning.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement du planning');
    }
  }

  Future<List<String>> getSites() async {
    final response = await http.get(Uri.parse('$baseUrl/sites'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['sites'] as List)
          .map((s) => s['name'] as String)
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des sites');
    }
  }

  Future<List<String>> getActivites() async {
    final response = await http.get(Uri.parse('$baseUrl/activites'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['activites'] ?? []);
    } else {
      throw Exception('Erreur lors du chargement des activités');
    }
  }

  Future<List<Activity>> searchActivities(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((a) => Activity.fromJson(a as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }

  Future<List<NewsItem>> getNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['news'] as List? ?? [])
          .map((n) => NewsItem.fromJson(n as Map<String, dynamic>))
          .toList();
    } else {
      // Pas encore implémenté côté serveur, retourner liste vide
      return [];
    }
  }

  // Enregistrer le token FCM pour les notifications
  Future<void> registerDevice(String fcmToken, List<String> subscribedActivities) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devices/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fcm_token': fcmToken,
        'subscribed_activities': subscribedActivities,
      }),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Silently fail for now - API not yet implemented
      print('Device registration not yet available');
    }
  }

  // Mettre à jour les préférences de notification
  Future<void> updateSubscriptions(String fcmToken, List<String> subscribedActivities) async {
    final response = await http.put(
      Uri.parse('$baseUrl/devices/subscriptions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fcm_token': fcmToken,
        'subscribed_activities': subscribedActivities,
      }),
    );
    
    if (response.statusCode != 200) {
      // Silently fail for now
      print('Subscription update not yet available');
    }
  }
}
