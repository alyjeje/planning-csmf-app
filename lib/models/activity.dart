class Activity {
  final int id;
  final String date;
  final String jour;
  final String? periode;
  final String heureDebut;
  final String heureFin;
  final String activite;
  final String? coach;
  final String? lieu;
  final String site;

  Activity({
    required this.id,
    required this.date,
    required this.jour,
    this.periode,
    required this.heureDebut,
    required this.heureFin,
    required this.activite,
    this.coach,
    this.lieu,
    required this.site,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      jour: json['jour'] ?? '',
      periode: json['periode'],
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      activite: json['activite'] ?? '',
      coach: json['coach'],
      lieu: json['lieu'],
      site: json['site'] ?? 'Bercy',
    );
  }

  String get timeRange => '$heureDebut - $heureFin';
  
  String get displayTitle {
    if (coach != null && coach!.isNotEmpty) {
      return '$activite - $coach';
    }
    return activite;
  }
}

class Planning {
  final String semaine;
  final String site;
  final List<String> sites;
  final String? prevSemaine;
  final String? nextSemaine;
  final Map<String, DayPlanning> planning;

  Planning({
    required this.semaine,
    required this.site,
    required this.sites,
    this.prevSemaine,
    this.nextSemaine,
    required this.planning,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    final planningData = json['planning'] as Map<String, dynamic>? ?? {};
    final Map<String, DayPlanning> planning = {};
    
    planningData.forEach((jour, data) {
      planning[jour] = DayPlanning.fromJson(data as Map<String, dynamic>);
    });

    return Planning(
      semaine: json['semaine'] ?? '',
      site: json['site'] ?? 'Bercy',
      sites: List<String>.from(json['sites'] ?? ['Bercy']),
      prevSemaine: json['prev_semaine'],
      nextSemaine: json['next_semaine'],
      planning: planning,
    );
  }
}

class DayPlanning {
  final String date;
  final Map<String, Map<String, List<Activity>>> periodes;

  DayPlanning({
    required this.date,
    required this.periodes,
  });

  factory DayPlanning.fromJson(Map<String, dynamic> json) {
    final periodesData = json['periodes'] as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, List<Activity>>> periodes = {};

    periodesData.forEach((periode, creneauxData) {
      final creneaux = creneauxData as Map<String, dynamic>;
      periodes[periode] = {};
      
      creneaux.forEach((creneau, activitiesData) {
        final activities = (activitiesData as List)
            .map((a) => Activity.fromJson(a as Map<String, dynamic>))
            .toList();
        periodes[periode]![creneau] = activities;
      });
    });

    return DayPlanning(
      date: json['date'] ?? '',
      periodes: periodes,
    );
  }

  List<Activity> get allActivities {
    final List<Activity> all = [];
    periodes.forEach((_, creneaux) {
      creneaux.forEach((_, activities) {
        all.addAll(activities);
      });
    });
    return all;
  }
}

class NewsItem {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String? imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
