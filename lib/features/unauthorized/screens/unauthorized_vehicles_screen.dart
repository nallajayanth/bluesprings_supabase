
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../home/widgets/custom_drawer.dart';
import '../../vehicle_registration/models/vehicle_model.dart';
import '../../vehicle_registration/services/vehicle_service.dart';

class UnauthorizedVehiclesScreen extends StatefulWidget {
  const UnauthorizedVehiclesScreen({super.key});

  @override
  State<UnauthorizedVehiclesScreen> createState() => _UnauthorizedVehiclesScreenState();
}

class _UnauthorizedVehiclesScreenState extends State<UnauthorizedVehiclesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final VehicleService _service = VehicleService();
  bool _isLoading = true;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getUnauthorizedVehicles();
      setState(() => _vehicles = data);
    } catch (e) {
      debugPrint('Error fetching unauthorized vehicles: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _authorizeVehicle(Vehicle vehicle) async {
    try {
      // Create updated vehicle object with authorized status
      final updatedVehicle = Vehicle(
        id: vehicle.id,
        vehicleNumber: vehicle.vehicleNumber,
        ownerName: vehicle.ownerName,
        vehicleType: vehicle.vehicleType,
        flatNumber: vehicle.flatNumber,
        blockName: vehicle.blockName,
        parkingSlot: vehicle.parkingSlot,
        residentType: vehicle.residentType,
        fastTagId: vehicle.fastTagId,
        status: 'Authorized',
        isBlocked: false,
        reason: null, // Clear reason
      );

      await _service.updateVehicle(updatedVehicle);
      
      _fetchVehicles(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle Access Authorized'),
            backgroundColor: Colors.green,
          ),
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
      drawer: const CustomDrawer(currentRoute: 'Unauthorize'),
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
             Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                   const Text(
                    'Unauthorized Vehicles',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                   ),
                   ElevatedButton.icon(
                      onPressed: () {
                         // This button could navigate to AddVehicleScreen or show a dialog
                         // For now let's just show a message or navigate to add vehicle
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use "Vehicle Registration" to add new blocked vehicles')));
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
                        : _vehicles.isEmpty 
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text('No unauthorized vehicles found'),
                                ),
                              )
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
                                             DataColumn(label: Text('Block Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                             DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                         ],
                                         rows: _vehicles.map((vehicle) {
                                            // We don't have block date in schema yet, using current date or created_at if available
                                            // For now just showing '-' or assuming it was blocked recently. 
                                            // Ideally schema should have `created_at` or `updated_at`.
                                            // Let's us show '-' for now or just today's date for demo if we want.
                                            final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now()); 

                                            return DataRow(
                                                cells: [
                                                    DataCell(Text(vehicle.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                    DataCell(Text(dateStr)), // Placeholder for block date
                                                    DataCell(
                                                       ConstrainedBox(
                                                          constraints: const BoxConstraints(maxWidth: 250),
                                                          child: Text(vehicle.reason ?? 'No reason provided', overflow: TextOverflow.ellipsis),
                                                       )
                                                    ),
                                                    DataCell(
                                                        Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                            decoration: BoxDecoration(
                                                                color: const Color(0xFFD32F2F),
                                                                borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: const Text(
                                                                'Unauthorized',
                                                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                            ),
                                                        )
                                                    ),
                                                    DataCell(
                                                        OutlinedButton.icon(
                                                            onPressed: () => _authorizeVehicle(vehicle),
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
