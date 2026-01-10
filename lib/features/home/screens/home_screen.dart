import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../models/dashboard_models.dart';
import '../widgets/activity_list_item.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/movement_chart.dart';
import '../widgets/recent_registration_item.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    WeeklyData(day: 'Mon', entries: 48, exits: 40),
    WeeklyData(day: 'Tue', entries: 35, exits: 30),
    WeeklyData(day: 'Wed', entries: 25, exits: 18),
    WeeklyData(day: 'Thu', entries: 28, exits: 34),
    WeeklyData(day: 'Fri', entries: 32, exits: 18),
    WeeklyData(day: 'Sat', entries: 40, exits: 45),
    WeeklyData(day: 'Sun', entries: 43, exits: 22),
  ];

  final List<ActivityLog> _activities = [
    ActivityLog(time: '19:29', vehicleNo: 'AP10FH2724', isEntry: true),
    ActivityLog(time: '19:53', vehicleNo: 'AP10FH2624', isEntry: false),
    ActivityLog(time: '22:14', vehicleNo: 'AP10FH9786', isEntry: true),
    ActivityLog(time: '22:14', vehicleNo: 'AP10FH9786', isEntry: true),
    ActivityLog(time: '19:53', vehicleNo: 'AP10FH2624', isEntry: false),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Vehicle Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.gradientStart,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
             onPressed: () {},
             icon: const Icon(Icons.person, color: Colors.white),
             label: const Text('System Administrator', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: 'Dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Updated 05 Jan 2026 17:30:52',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statistics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine width for 2 columns. 
                // Available width is (screen width - padding).
                // Spacing is 16.
                // Item width = (maxWidth - spacing) / 2
                final itemWidth = (constraints.maxWidth - 16) / 2;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: StatCard(
                        label: _stats[0].label,
                        value: _stats[0].value,
                        icon: Icons.directions_car,
                        iconColor: Color(_stats[0].color),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: StatCard(
                        label: _stats[1].label,
                        value: _stats[1].value,
                        icon: Icons.login,
                        iconColor: Color(_stats[1].color),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: StatCard(
                        label: _stats[2].label,
                        value: _stats[2].value,
                        icon: Icons.logout,
                        iconColor: Color(_stats[2].color),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: StatCard(
                        label: _stats[3].label,
                        value: _stats[3].value,
                        icon: Icons.person_pin,
                        iconColor: Color(_stats[3].color),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // Chart and Recent Activity Section
            // In mobile, we might stack them. In tablet/desktop, we could side-by-side.
            // For now, stacking them vertically for mobile primarily.
            Column(
              children: [
                 MovementChart(data: _weeklyData),
                 const SizedBox(height: 20),
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
                         children: const [
                           Expanded(
                             child: Text(
                               'Recent Activity',
                               style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.textPrimary,
                               ),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                           SizedBox(width: 8),
                           Text(
                             '8 activities',
                              style: TextStyle(
                               fontSize: 12,
                               color: AppColors.textSecondary,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 16),
                       ListView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: _activities.length,
                         itemBuilder: (context, index) {
                           return ActivityListItem(activity: _activities[index]);
                         },
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
                     children: const [
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
                       SizedBox(width: 8),
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
                   // Headers
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                     child: rowHeader(),
                   ),
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
      ),
    );
  }

  Widget rowHeader() {
    // Hidden on mobile or used as reference? 
    // The design shows headers. Let's keep it simple for now as the items themselves have labels.
    // Or we can just display a simple row of text.
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: const [
         Text('VEHICLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
         // Other headers are inside the card in mobile view usually, but let's stick to design
       ],
     );
  }


}
