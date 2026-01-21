import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../models/activity.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../widgets/activity_card.dart';
import '../constants/colors.dart';
import 'settings_screen.dart';
import 'news_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Planning? _planning;
  bool _isLoading = true;
  String? _error;
  Set<String> _selectedCategories = {};
  bool _filterActive = false;
  
  // Catégories d'activités (même logique que le site)
  static const List<Map<String, dynamic>> _categories = [
    {'key': 'cardio', 'label': 'Cardio / HIIT', 'icon': Icons.directions_run, 'color': Color(0xFFEF4444)},
    {'key': 'cardio-seniors', 'label': 'Cardio Seniors', 'icon': Icons.elderly, 'color': Color(0xFF06B6D4)},
    {'key': 'yoga', 'label': 'Yoga', 'icon': Icons.self_improvement, 'color': Color(0xFF8B5CF6)},
    {'key': 'pilates', 'label': 'Pilates', 'icon': Icons.self_improvement, 'color': Color(0xFFEC4899)},
    {'key': 'musculation', 'label': 'Musculation', 'icon': Icons.fitness_center, 'color': Color(0xFFF97316)},
    {'key': 'combat', 'label': 'Sports de combat', 'icon': Icons.sports_mma, 'color': Color(0xFF1E293B)},
    {'key': 'badminton', 'label': 'Badminton', 'icon': Icons.sports_tennis, 'color': Color(0xFF22C55E)},
    {'key': 'escalade', 'label': 'Escalade', 'icon': Icons.terrain, 'color': Color(0xFFEAB308)},
    {'key': 'danse', 'label': 'Danse / Zumba', 'icon': Icons.music_note, 'color': Color(0xFFF43F5E)},
    {'key': 'stretching', 'label': 'Stretching', 'icon': Icons.accessibility_new, 'color': Color(0xFF14B8A6)},
    {'key': 'autre', 'label': 'Autres', 'icon': Icons.sports, 'color': Color(0xFF94A3B8)},
  ];

  // Convertit une heure "HH:MM" en minutes
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Détermine la catégorie d'une activité (même logique que le site)
  String _getCategory(String name, String? heureDebut) {
    final n = name.toLowerCase();
    
    // Espace Cardio entre 9h30 et 11h = réservé seniors
    if (n.contains('espace cardio') && heureDebut != null) {
      final minutes = _timeToMinutes(heureDebut);
      // 9h30 = 570 minutes, 11h = 660 minutes
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadPlanning();
  }

  Future<void> _loadPlanning({String? semaine}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final prefs = context.read<PreferencesService>();
      
      final planning = await apiService.getPlanning(
        semaine: semaine,
        site: prefs.selectedSite,
      );
      
      setState(() {
        _planning = planning;
        // Par défaut, toutes les catégories sont sélectionnées
        if (_selectedCategories.isEmpty) {
          _selectedCategories = _categories.map((c) => c['key'] as String).toSet();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo CSMF
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CSMFColors.jaune,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'csmf',
                  style: TextStyle(
                    color: CSMFColors.bleuPrimaire,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('CSMF Planning'),
          ],
        ),
        actions: [
          // Bouton filtre avec badge si actif
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (_filterActive)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: CSMFColors.jaune,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPlanningTab(),
          const NewsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Actualités',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CSMFColors.bleuPrimaire),
            const SizedBox(height: 16),
            Text(
              'Chargement du planning...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: CSMFColors.jaune,
                foregroundColor: CSMFColors.bleuPrimaire,
              ),
              onPressed: () => _loadPlanning(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_planning == null) {
      return const Center(child: Text('Aucun planning disponible'));
    }

    return RefreshIndicator(
      color: CSMFColors.bleuPrimaire,
      onRefresh: () => _loadPlanning(semaine: _planning?.semaine),
      child: Column(
        children: [
          // Sélecteur de site et navigation semaine
          _buildHeader(),
          // Indicateur de filtre actif
          if (_filterActive)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CSMFColors.bleuPrimaire.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CSMFColors.bleuPrimaire.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 18, color: CSMFColors.bleuPrimaire),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedCategories.length} catégorie${_selectedCategories.length > 1 ? 's' : ''} sélectionnée${_selectedCategories.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: CSMFColors.bleuPrimaire,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategories = _categories.map((c) => c['key'] as String).toSet();
                        _filterActive = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CSMFColors.bleuPrimaire,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Planning
          Expanded(
            child: _buildPlanningList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final prefs = context.watch<PreferencesService>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CSMFColors.grisClair,
      ),
      child: Column(
        children: [
          // Sélecteur de site
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 20, color: CSMFColors.bleuPrimaire),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: prefs.selectedSite,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(Icons.keyboard_arrow_down, color: CSMFColors.bleuPrimaire),
                    items: (_planning?.sites ?? ['Bercy']).map((site) {
                      return DropdownMenuItem(
                        value: site,
                        child: Text(site, style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (site) {
                      if (site != null) {
                        prefs.setSelectedSite(site);
                        _loadPlanning(semaine: _planning?.semaine);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Navigation semaine
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CSMFColors.bleuPrimaire.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: CSMFColors.bleuPrimaire),
                  onPressed: _planning?.prevSemaine != null
                      ? () => _loadPlanning(semaine: _planning!.prevSemaine)
                      : null,
                ),
                Column(
                  children: [
                    Text(
                      'Semaine du',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatWeekDate(_planning?.semaine ?? ''),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CSMFColors.bleuPrimaire,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: CSMFColors.bleuPrimaire),
                  onPressed: _planning?.nextSemaine != null
                      ? () => _loadPlanning(semaine: _planning!.nextSemaine)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWeekDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildPlanningList() {
    if (_planning == null) return const SizedBox();

    final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final planningJours = _planning!.planning;
    
    // Date du jour pour filtrer les jours passés
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jours.length,
      itemBuilder: (context, index) {
        final jour = jours[index];
        final dayPlanning = planningJours[jour];
        
        if (dayPlanning == null || dayPlanning.allActivities.isEmpty) {
          return const SizedBox();
        }
        
        // Ne pas afficher les jours passés de la semaine en cours
        if (dayPlanning.date.compareTo(todayStr) < 0) {
          return const SizedBox();
        }

        return _buildDaySection(jour, dayPlanning);
      },
    );
  }

  // Vérifie si une activité correspond à une catégorie sélectionnée
  bool _activityMatchesFilter(Activity activity) {
    final category = _getCategory(activity.activite, activity.heureDebut);
    return _selectedCategories.contains(category);
  }

  Widget _buildDaySection(String jour, DayPlanning dayPlanning) {
    // Filtrer par catégorie et trier les activités
    final activities = dayPlanning.allActivities
        .where((a) => _activityMatchesFilter(a))
        .toList();
    activities.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
    
    // Ne pas afficher le jour s'il n'y a pas d'activités après filtrage
    if (activities.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du jour
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CSMFColors.bleuPrimaire, CSMFColors.bleuSecondaire],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: CSMFColors.bleuPrimaire.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                jour,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDate(dayPlanning.date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CSMFColors.bleuPrimaire,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Liste des activités triées par heure
        ...activities.map((activity) => ActivityCard(activity: activity)),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: CSMFColors.bleuPrimaire),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Filtrer par activité',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategories = _categories.map((c) => c['key'] as String).toSet();
                          });
                        },
                        child: const Text('Tout'),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategories = {};
                          });
                        },
                        child: const Text('Aucun'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Grille de chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final key = cat['key'] as String;
                      final label = cat['label'] as String;
                      final icon = cat['icon'] as IconData;
                      final color = cat['color'] as Color;
                      final isSelected = _selectedCategories.contains(key);
                      
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isSelected ? Colors.white : color,
                            ),
                            const SizedBox(width: 6),
                            Text(label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedCategories.add(key);
                            } else {
                              _selectedCategories.remove(key);
                            }
                          });
                        },
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? color : Colors.grey[300]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Bouton appliquer
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: CSMFColors.bleuPrimaire,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          _filterActive = _selectedCategories.length != _categories.length;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        _selectedCategories.isEmpty
                            ? 'Aucune activité sélectionnée'
                            : 'Appliquer le filtre',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d/MM', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
