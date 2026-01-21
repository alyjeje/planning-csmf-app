import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../constants/colors.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final activityColor = CSMFColors.getColorForActivity(activity.activite, heureDebut: activity.heureDebut);
    final activityIcon = CSMFColors.getIconForActivity(activity.activite, heureDebut: activity.heureDebut);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showActivityDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: activityColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de l'activité
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: activityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activityIcon,
                    color: activityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Détails activité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activite,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (activity.coach != null && activity.coach!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: CSMFColors.bleuPrimaire,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.coach!,
                              style: TextStyle(
                                fontSize: 13,
                                color: CSMFColors.bleuPrimaire,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.timeRange,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (activity.lieu != null && activity.lieu!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.room,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.lieu!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge horaire - meilleure lisibilité
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: CSMFColors.bleuPrimaire,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        activity.heureDebut,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.heureFin,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context) {
    final activityColor = CSMFColors.getColorForActivity(activity.activite, heureDebut: activity.heureDebut);
    final activityIcon = CSMFColors.getIconForActivity(activity.activite, heureDebut: activity.heureDebut);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        activityIcon,
                        color: activityColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        activity.activite,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  Icons.access_time,
                  'Horaire',
                  activity.timeRange,
                  activityColor,
                ),
                if (activity.coach != null)
                  _buildDetailRow(
                    context,
                    Icons.person,
                    'Coach',
                    activity.coach!,
                    activityColor,
                  ),
                if (activity.lieu != null)
                  _buildDetailRow(
                    context,
                    Icons.room,
                    'Lieu',
                    activity.lieu!,
                    activityColor,
                  ),
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  'Site',
                  activity.site,
                  activityColor,
                ),
                _buildDetailRow(
                  context,
                  Icons.calendar_today,
                  'Date',
                  '${activity.jour} ${activity.date}',
                  activityColor,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: CSMFColors.jaune,
                      foregroundColor: CSMFColors.bleuPrimaire,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification activée pour ce cours'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: CSMFColors.bleuPrimaire,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Activer les rappels', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
