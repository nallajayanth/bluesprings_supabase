
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../home/widgets/custom_drawer.dart';
import '../models/unauthorized_vehicle_model.dart';
import '../services/unauthorized_service.dart';

class UnauthorizedVehiclesScreen extends StatefulWidget {
  const UnauthorizedVehiclesScreen({super.key});

  @override
  State<UnauthorizedVehiclesScreen> createState() => _UnauthorizedVehiclesScreenState();
}

class _UnauthorizedVehiclesScreenState extends State<UnauthorizedVehiclesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UnauthorizedService _service = UnauthorizedService();
  bool _isLoading = true;
  List<UnauthorizedVehicle> _vehicles = [];

  // Static mock data for fallback/demo if Supabase is empty/fails
  final List<UnauthorizedVehicle> _mockVehicles = [
    UnauthorizedVehicle(
      id: 1,
      vehicleNumber: 'MH01XY9999',
      unauthorizedDate: DateTime(2025, 12, 28, 12, 49),
      reason: 'Unauthorized entry multiple times',
      status: 'Unauthorized',
    ),
     UnauthorizedVehicle(
      id: 2,
      vehicleNumber: 'TS08UB5555',
      unauthorizedDate: DateTime(2025, 12, 29, 10, 15),
      reason: 'Blacklisted due to parking violation',
      status: 'Unauthorized',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getUnauthorizedVehicles();
      if (data.isEmpty && mounted) {
        // Use Mock data if DB is empty for demo purposes, 
        // normally we would just show empty state
        // setState(() => _vehicles = _mockVehicles);
        setState(() => _vehicles = []);
      } else {
        setState(() => _vehicles = data);
      }
    } catch (e) {
      debugPrint('Error fetching unauthorized vehicles: $e');
      if (mounted) {
         // Fallback to mock data on error (e.g. table doesn't exist yet)
         setState(() => _vehicles = _mockVehicles);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Showing demo data. Error: $e')),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _authorizeVehicle(int id) async {
    try {
      // Optimistic update
      // await _service.updateStatus(id, 'Authorized'); 
      // OR Delete depending on requirement. The UI shows 'Authorized' button which implies changing status.
      // But typically "Unauthorize New Vehicle" adds to list. "Authorized" might remove or mark resolved.
      // Let's assume it removes it or marks it authorized.
      
      // Let's delete it for now as "Authorized" means it's no longer unauthorized
      await _service.deleteUnauthorizedVehicle(id);
      
      _fetchVehicles(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Access Authorized')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const CustomDrawer(),
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
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header Row
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
                    'Unauthorized Vehicles',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                   ),
                   ElevatedButton.icon(
                      onPressed: () {
                         // TODO: Show dialog to add new unauthorized vehicle
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
                      },
                      icon: const Icon(Icons.block, color: Colors.white, size: 18),
                      label: const Text('Unauthorize New Vehicle'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F), // Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                   ),
                ],
             ),
             const SizedBox(height: 24),
             
             // Data Card
             Card(
                 elevation: 2,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: _isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                             width: double.infinity,
                             child: SingleChildScrollView(
                                 scrollDirection: Axis.horizontal,
                                 child: DataTable(
                                     headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                     columnSpacing: 40,
                                     horizontalMargin: 0,
                                     columns: const [
                                         DataColumn(label: Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                         DataColumn(label: Text('Unauthorized Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                         DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
                                         DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                         DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                     ],
                                     rows: _vehicles.map((vehicle) {
                                        return DataRow(
                                            cells: [
                                                DataCell(Text(vehicle.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                DataCell(Text(DateFormat('dd-MM-yyyy HH:mm').format(vehicle.unauthorizedDate))),
                                                DataCell(
                                                   ConstrainedBox(
                                                      constraints: const BoxConstraints(maxWidth: 250),
                                                      child: Text(vehicle.reason, overflow: TextOverflow.ellipsis),
                                                   )
                                                ),
                                                DataCell(
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                            color: const Color(0xFFD32F2F),
                                                            borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                            vehicle.status,
                                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                        ),
                                                    )
                                                ),
                                                DataCell(
                                                    OutlinedButton.icon(
                                                        onPressed: () => _authorizeVehicle(vehicle.id ?? 0),
                                                        icon: const Icon(Icons.check_circle_outline, size: 16),
                                                        label: const Text('Authorized'),
                                                        style: OutlinedButton.styleFrom(
                                                            foregroundColor: const Color(0xFF2E7D32), // Green
                                                            side: const BorderSide(color: Color(0xFF2E7D32)),
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                        ),
                                                    )
                                                ),
                                            ]
                                        );
                                     }).toList(),
                                 ),
                             ),
                         ),
                 ),
             ),
          ],
        ),
      ),
    );
  }
}
