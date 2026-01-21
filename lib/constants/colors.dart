import 'package:flutter/material.dart';

class CSMFColors {
  // Couleurs principales CSMF
  static const Color bleuPrimaire = Color(0xFF1E3A6E);  // Bleu marine du logo
  static const Color bleuSecondaire = Color(0xFF2D5A9E); // Bleu plus clair
  static const Color jaune = Color(0xFFFFD700);          // Jaune du logo
  static const Color jauneClair = Color(0xFFFFF8E1);     // Jaune très pâle (moins intense)
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color grisClair = Color(0xFFF5F5F5);
  
  // Couleurs par catégorie d'activité (même que le site)
  static const Map<String, Color> categorieColors = {
    'cardio': Color(0xFFEF4444),       // Rouge
    'cardio-seniors': Color(0xFF06B6D4), // Cyan
    'yoga': Color(0xFF8B5CF6),          // Violet
    'pilates': Color(0xFFEC4899),       // Rose
    'musculation': Color(0xFFF97316),   // Orange
    'combat': Color(0xFF1E293B),        // Gris foncé
    'badminton': Color(0xFF22C55E),     // Vert
    'escalade': Color(0xFFEAB308),      // Jaune
    'danse': Color(0xFFF43F5E),         // Rose rouge
    'stretching': Color(0xFF14B8A6),    // Teal
    'autre': Color(0xFF94A3B8),         // Gris
  };

  // Icônes par catégorie
  static const Map<String, IconData> categorieIcons = {
    'cardio': Icons.directions_run,
    'cardio-seniors': Icons.elderly,
    'yoga': Icons.self_improvement,
    'pilates': Icons.self_improvement,
    'musculation': Icons.fitness_center,
    'combat': Icons.sports_mma,
    'badminton': Icons.sports_tennis,
    'escalade': Icons.terrain,
    'danse': Icons.music_note,
    'stretching': Icons.accessibility_new,
    'autre': Icons.sports,
  };

  // Convertit une heure "HH:MM" en minutes
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Détermine la catégorie d'une activité (même logique que le site)
  static String getCategoryForActivity(String name, {String? heureDebut}) {
    final n = name.toLowerCase();
    
    // Espace Cardio entre 9h30 et 11h = réservé seniors
    if (n.contains('espace cardio') && heureDebut != null) {
      final minutes = _timeToMinutes(heureDebut);
      if (minutes >= 570 && minutes < 660) {
        return 'cardio-seniors';
      }
    }
    
    // Cours Séniors → Cardio Seniors
    if (n.contains('séniors') || n.contains('seniors')) {
      return 'cardio-seniors';
    }
    
    // Cardio
    final cardioKeywords = ['cardio', 'hiit', 'circuit', 'cross training', 'full body', 'caf', 'abdos'];
    for (final kw in cardioKeywords) {
      if (n.contains(kw)) return 'cardio';
    }
    
    // Yoga
    if (n.contains('yoga')) return 'yoga';
    
    // Pilates
    if (n.contains('pilates')) return 'pilates';
    
    // Musculation
    final muscuKeywords = ['musculation', 'muscu', 'renforcement', 'body sculpt'];
    for (final kw in muscuKeywords) {
      if (n.contains(kw)) return 'musculation';
    }
    
    // Sports de combat
    final combatKeywords = ['boxe', 'boxing', 'combat', 'mma', 'kick', 'self'];
    for (final kw in combatKeywords) {
      if (n.contains(kw)) return 'combat';
    }
    
    // Badminton
    if (n.contains('badminton') || n.contains('bad')) return 'badminton';
    
    // Escalade
    if (n.contains('escalade') || n.contains('grimpe')) return 'escalade';
    
    // Danse
    final danseKeywords = ['danse', 'zumba', 'salsa', 'hip hop'];
    for (final kw in danseKeywords) {
      if (n.contains(kw)) return 'danse';
    }
    
    // Stretching
    if (n.contains('stretching') || n.contains('étirement') || n.contains('souplesse')) return 'stretching';
    
    return 'autre';
  }

  static Color getColorForActivity(String activite, {String? heureDebut}) {
    final category = getCategoryForActivity(activite, heureDebut: heureDebut);
    return categorieColors[category] ?? categorieColors['autre']!;
  }

  static IconData getIconForActivity(String activite, {String? heureDebut}) {
    final category = getCategoryForActivity(activite, heureDebut: heureDebut);
    return categorieIcons[category] ?? categorieIcons['autre']!;
  }
}
