import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../vehicle_registration/screens/vehicle_registration_screen.dart';
import '../../reports/screens/movement_reports_screen.dart';
import '../../reports/screens/visitor_duration_screen.dart';
import '../../unauthorized/screens/unauthorized_vehicles_screen.dart';
import '../screens/home_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                    Icons.directions_car,
                    size: 48,
                    color: AppColors.gradientStart,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vehicle Monitoring',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gradientStart,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard_outlined, 'Dashboard', currentRoute == 'Dashboard'),
          _buildDrawerItem(context, Icons.car_rental, 'Vehicle Registration', currentRoute == 'Vehicle Registration'),
          _buildDrawerItem(context, Icons.analytics_outlined, 'Movement Reports', currentRoute == 'Movement Reports'),
          _buildDrawerItem(context, Icons.timer_outlined, 'Visitor Duration', currentRoute == 'Visitor Duration'),
          _buildDrawerItem(context, Icons.do_not_disturb_on_outlined, 'Unauthorize', currentRoute == 'Unauthorize'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFFE8F5E9), // Light green tint
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF2E7D32) : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E7D32) : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (title == 'Dashboard') {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else if (title == 'Vehicle Registration') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
            );
          } else if (title == 'Movement Reports') {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MovementReportsScreen()),
            );
          } else if (title == 'Visitor Duration') {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VisitorDurationScreen()),
            );
          } else if (title == 'Unauthorize') {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UnauthorizedVehiclesScreen()),
            );
          } else {
             // Other items implementation pending
          }
        },
      ),
    );
  }
}
