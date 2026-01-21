import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _allActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final apiService = context.read<ApiService>();
      final activities = await apiService.getActivites();
      setState(() {
        _allActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Site par défaut
        _buildSectionTitle('Site par défaut'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Site favori'),
            subtitle: Text(prefs.selectedSite),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSiteSelector(context, prefs),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Section Notifications
        _buildSectionTitle('Notifications'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Notifier tous les cours'),
                subtitle: const Text('Recevoir les notifications pour toutes les activités'),
                value: prefs.notifyAll,
                onChanged: (value) {
                  prefs.setNotifyAll(value);
                },
              ),
              if (!prefs.notifyAll) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title: const Text('Choisir les cours'),
                  subtitle: Text(
                    prefs.subscribedActivities.isEmpty
                        ? 'Aucun cours sélectionné'
                        : '${prefs.subscribedActivities.length} cours sélectionnés',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showActivitySelector(context, prefs),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Section À propos
        _buildSectionTitle('À propos'),
        Card(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: CSMFColors.jaune,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/logo_csmf.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              'csmf',
                              style: TextStyle(
                                color: CSMFColors.bleuPrimaire,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CSMF Paris',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CSMFColors.bleuPrimaire,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Club Sportif du Ministère des Finances',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info_outline, color: CSMFColors.bleuPrimaire),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CSMFColors.bleuPrimaire,
        ),
      ),
    );
  }

  void _showSiteSelector(BuildContext context, PreferencesService prefs) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choisir le site par défaut',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...['Bercy', 'Paganini', 'Ivry', 'Noisy le Grand', 'Bellan', 'Sieyès', 'Montaigne'].map((site) {
                return ListTile(
                  title: Text(site),
                  trailing: prefs.selectedSite == site
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    prefs.setSelectedSite(site);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showActivitySelector(BuildContext context, PreferencesService prefs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sélectionner les cours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          prefs.setSubscribedActivities([]);
                        },
                        child: const Text('Tout désélectionner'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _allActivities.length,
                      itemBuilder: (context, index) {
                        final activity = _allActivities[index];
                        final isSubscribed = prefs.subscribedActivities.contains(activity);
                        
                        return CheckboxListTile(
                          title: Text(activity),
                          value: isSubscribed,
                          onChanged: (value) {
                            prefs.toggleActivitySubscription(activity);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
