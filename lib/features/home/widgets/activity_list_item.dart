import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/dashboard_models.dart';

class ActivityListItem extends StatelessWidget {
  final ActivityLog activity;

  const ActivityListItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              activity.time,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              activity.vehicleNo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: activity.isEntry
                  ? const Color(0xFFE8F5E9) // Light Green
                  : const Color(0xFFE0F7FA), // Light Cyan
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity.isEntry ? 'ENTRY' : 'EXIT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: activity.isEntry
                    ? const Color(0xFF2E7D32) // Dark Green
                    : const Color(0xFF006064), // Dark Cyan
              ),
            ),
          ),
        ],
      ),
    );
  }
}
