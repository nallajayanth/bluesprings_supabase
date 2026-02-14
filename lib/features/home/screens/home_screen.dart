import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../models/dashboard_models.dart';


import '../widgets/movement_chart.dart';
import '../widgets/recent_registration_item.dart';
import '../../vehicle_registration/screens/vehicle_registration_screen.dart';

import '../../unauthorized/screens/unauthorized_vehicles_screen.dart';
import '../../reports/screens/movement_reports_screen.dart';
import '../../reports/screens/visitor_duration_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Dummy Data
  final List<StatData> _stats = [
    StatData(
      label: 'TOTAL VEHICLES',
      value: '7',
      iconPath: '',
      color: 0xFF5C6BC0,
    ),
    StatData(
      label: 'TODAY ENTRIES',
      value: '0',
      iconPath: '',
      color: 0xFF43A047,
    ),
    StatData(
      label: 'TODAY EXITS',
      value: '0',
      iconPath: '',
      color: 0xFF00ACC1,
    ),
    StatData(
      label: 'VISITORS TODAY',
      value: '0',
      iconPath: '',
      color: 0xFFF57F17,
    ),
  ];

  final List<WeeklyData> _weeklyData = [
    WeeklyData(day: 'Mon', entry2W: 24, entry4W: 24, exit2W: 20, exit4W: 20),
    WeeklyData(day: 'Tue', entry2W: 15, entry4W: 20, exit2W: 15, exit4W: 15),
    WeeklyData(day: 'Wed', entry2W: 10, entry4W: 15, exit2W: 8, exit4W: 10),
    WeeklyData(day: 'Thu', entry2W: 14, entry4W: 14, exit2W: 17, exit4W: 17),
    WeeklyData(day: 'Fri', entry2W: 16, entry4W: 16, exit2W: 9, exit4W: 9),
    WeeklyData(day: 'Sat', entry2W: 20, entry4W: 20, exit2W: 22, exit4W: 23),
    WeeklyData(day: 'Sun', entry2W: 21, entry4W: 22, exit2W: 11, exit4W: 11),
  ];

  final List<ActivityLog> _activities = [
    ActivityLog(time: '21:13:58', date: '11/02/2026', vehicleNo: 'WB12AB1030', type: '4W', isEntry: true, status: 'Valid'),
    ActivityLog(time: '19:39:08', date: '11/02/2026', vehicleNo: 'WB12AB1017', type: '2W', isEntry: false, status: 'Valid'),
    ActivityLog(time: '18:40:58', date: '11/02/2026', vehicleNo: 'WB12AB1022', type: '2W', isEntry: false, status: 'Invalid'),
    ActivityLog(time: '18:31:01', date: '11/02/2026', vehicleNo: 'WB12AB1030', type: '4W', isEntry: true, status: 'Valid'),
    ActivityLog(time: '17:13:40', date: '11/02/2026', vehicleNo: 'WB12AB1013', type: '4W', isEntry: false, status: 'Valid'),
  ];

  final List<RegisteredVehicle> _registrations = [
    RegisteredVehicle(
      vehicleNo: 'TS10D8935',
      owner: 'Maruthi Taddii',
      type: 'Car',
      flat: 'A-323',
      status: 'Authorized',
      date: '29 Dec 2025',
    ),
    RegisteredVehicle(
      vehicleNo: 'TG08HF0909',
      owner: 'Kiran Mande',
      type: 'Van',
      flat: 'A-001',
      status: 'Authorized',
      date: '04 Jan 2026',
    ),
    RegisteredVehicle(
      vehicleNo: 'TG08HF0909',
      owner: 'Kiran Mande',
      type: 'Van',
      flat: 'A-001',
      status: 'Authorized',
      date: '04 Jan 2026',
    ),
    RegisteredVehicle(
      vehicleNo: 'TS10D8935',
      owner: 'Maruthi Taddii',
      type: 'Car',
      flat: 'A-323',
      status: 'Authorized',
      date: '29 Dec 2025',
    ),
  ];

  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _signOut(context); // Perform logout
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Title Section
          Card(
             elevation: 2,
             color: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: AppColors.navBarBlue,
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: const Icon(Icons.analytics, color: Colors.white, size: 28),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text(
                               'Parking Analytics',
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                             ),
                             Row(
                               children: [
                                 Container(
                                   width: 8, height: 8,
                                   decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                 ),
                                 const SizedBox(width: 6),
                                 const Text('Live monitoring', style: TextStyle(color: Colors.grey, fontSize: 13)),
                               ],
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                         color: Colors.grey.shade50,
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const TextField(
                         decoration: InputDecoration(
                            hintText: 'Search vehicle number...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                         ),
                      ),
                   ),
                 ],
               ),
             ),
          ),
          const SizedBox(height: 16),

          // Statistics Grid (6 Cards)
          LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth;
              if (constraints.maxWidth > 1000) {
                 cardWidth = (constraints.maxWidth - (5 * 16)) / 6;
              } else if (constraints.maxWidth > 600) {
                 cardWidth = (constraints.maxWidth - (2 * 16)) / 3;
              } else {
                 cardWidth = (constraints.maxWidth - 16) / 2;
              }
              
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('16', 'ENTRIES', Icons.arrow_forward, AppColors.cardGreen, cardWidth),
                  _buildStatCard('19', 'EXITS', Icons.arrow_back, AppColors.cardRed, cardWidth),
                  _buildStatCard('15', 'NEW', Icons.star, AppColors.cardOrange, cardWidth),
                  _buildStatCard('50', 'RECURRING', Icons.refresh, AppColors.cardBlue, cardWidth),
                  _buildStatCard('18', '2-WHEELER', Icons.two_wheeler, AppColors.cardCyan, cardWidth),
                  _buildStatCard('32', '4-WHEELER', Icons.directions_car, AppColors.cardPurple, cardWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Chart and Recent Activity Section
          Column(
            children: [
               MovementChart(data: _weeklyData),
               const SizedBox(height: 16),
               Container(
                 padding: const EdgeInsets.symmetric(vertical: 24), // Removed horizontal padding for scroll
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text(
                             'Recent Activity',
                             style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                               color: AppColors.textPrimary,
                             ),
                           ),
                           const SizedBox(height: 4),
                           const Text(
                             'Last 50 events',
                             style: TextStyle(color: Colors.grey, fontSize: 13),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 16),
                     const Divider(height: 1),
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 24),
                         child: DataTable(
                           horizontalMargin: 0,
                           columnSpacing: 20,
                           dataRowMinHeight: 60, // Increased height for multi-line content
                           dataRowMaxHeight: 60,
                           headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                           columns: const [
                             DataColumn(label: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                             DataColumn(label: Text('VEHICLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                             DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                             DataColumn(label: Text('GATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                             DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                           ],
                           rows: _activities.map((log) {
                             return DataRow(
                               cells: [
                                 DataCell(
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text(log.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                       Text(log.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                     ],
                                   ),
                                 ),
                                 DataCell(
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: Colors.grey.shade100,
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Text(log.vehicleNo, style: const TextStyle(fontWeight: FontWeight.w600)),
                                   ),
                                 ),
                                 DataCell(
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: log.type == '2W' ? AppColors.cardBlue.withOpacity(0.1) : AppColors.cardPurple.withOpacity(0.1),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Row( // Icon + Text
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           log.type == '2W' ? Icons.two_wheeler : Icons.directions_car,
                                           size: 16,
                                           color: log.type == '2W' ? AppColors.cardBlue : AppColors.cardPurple,
                                         ),
                                         const SizedBox(width: 4),
                                         Text(
                                           log.type,
                                           style: TextStyle(
                                             color: log.type == '2W' ? AppColors.cardBlue : AppColors.cardPurple,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 12,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                                 DataCell(
                                   Container( // Entry/Exit Badge
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: log.isEntry ? AppColors.cardGreen.withOpacity(0.1) : AppColors.cardRed.withOpacity(0.1),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           log.isEntry ? Icons.arrow_forward : Icons.arrow_back,
                                           size: 14,
                                           color: log.isEntry ? AppColors.cardGreen : AppColors.cardRed,
                                         ),
                                         const SizedBox(width: 4),
                                         Text(
                                           log.isEntry ? 'ENTRY' : 'EXIT',
                                           style: TextStyle(
                                             color: log.isEntry ? AppColors.cardGreen : AppColors.cardRed,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 11,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                                 DataCell(
                                   Container( // Valid/Invalid Badge
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: log.status == 'Valid' ? AppColors.cardGreen.withOpacity(0.1) : AppColors.cardRed.withOpacity(0.1),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           log.status == 'Valid' ? Icons.check : Icons.close,
                                           size: 14,
                                           color: log.status == 'Valid' ? AppColors.cardGreen : AppColors.cardRed,
                                         ),
                                         const SizedBox(width: 4),
                                         Text(
                                           log.status.toUpperCase(),
                                           style: TextStyle(
                                             color: log.status == 'Valid' ? AppColors.cardGreen : AppColors.cardRed,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 11,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             );
                           }).toList(),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
            ],
          ),
          const SizedBox(height: 30),

          // Registrations List
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                   offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Expanded(
                       child: Text(
                         'Recently Registered Vehicles',
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: AppColors.textPrimary,
                         ),
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       '7 vehicles',
                        style: TextStyle(
                         fontSize: 12,
                         color: AppColors.textSecondary,
                        ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 20),
                 const Divider(),
                 ListView.builder(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: _registrations.length,
                   itemBuilder: (context, index) {
                     return RecentRegistrationItem(vehicle: _registrations[index]);
                   },
                 ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.dashboardBackground,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                'RFID System',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              backgroundColor: AppColors.navBarBlue,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navBarBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Vehicles'),
          BottomNavigationBarItem(icon: Icon(Icons.do_not_disturb_on), label: 'Unauthorized'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const VehicleRegistrationScreen();
      case 2:
        return const UnauthorizedVehiclesScreen();
      case 3:
        return _buildReportsMenu();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildReportsMenu() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navBarBlue,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
      ),
      backgroundColor: AppColors.dashboardBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReportMenuItem(
              'Movement Reports',
              'View detailed logs of vehicle entries and exits.',
              Icons.analytics_outlined,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MovementReportsScreen())),
            ),
            const SizedBox(height: 16),
            _buildReportMenuItem(
              'Visitor Duration',
              'Track how long visitors stay within the premises.',
              Icons.timer_outlined,
              Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitorDurationScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportMenuItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }



  Widget _buildStatCard(String value, String label, IconData icon, Color color, double width) {
    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row( // changed to Row for the specific design in image
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
             Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                     Text(
                        value,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                     ),
                     const SizedBox(height: 4),
                     Text(
                        label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
                     ),
                 ],
             ),
             Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                     color: color.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                 ),
                 child: Icon(icon, color: color, size: 24),
             ),
        ],
      ),
    );
  }
}
