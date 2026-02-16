import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/widgets/custom_drawer.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import 'add_vehicle_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;

  // Filters
  String _searchQuery = '';
  String _selectedType = 'All Types';
  String _selectedGroup = 'All Groups';
  String _selectedStatus = 'All Status';
  String _selectedInside = 'All';

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _filterVehicles();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
            _isLoading = false;
             _filterVehicles();
        });
        if (e.toString().contains('Select')) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error loading vehicles: $e')),
             );
        }
      }
    }
  }

  void _filterVehicles() {
    setState(() {
      _filteredVehicles = _vehicles.where((vehicle) {
        final matchesSearch = vehicle.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehicle.ownerName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesType = _selectedType == 'All Types' || 
            vehicle.vehicleType.toLowerCase() == _selectedType.toLowerCase();
        
        final matchesGroup = _selectedGroup == 'All Groups' || 
            vehicle.group.toLowerCase() == _selectedGroup.toLowerCase();
        
        final matchesStatus = _selectedStatus == 'All Status' || 
                              (_selectedStatus == 'Authorized' && vehicle.status == 'Authorized') ||
                              (_selectedStatus == 'Unauthorized' && (vehicle.status == 'Unauthorized' || vehicle.status == 'Blocked' || vehicle.isBlocked));
                              
        final matchesInside = _selectedInside == 'All' ||
                              (_selectedInside == 'Inside' && vehicle.isInside) ||
                              (_selectedInside == 'Outside' && !vehicle.isInside);

        return matchesSearch && matchesType && matchesGroup && matchesStatus && matchesInside;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = 'All Types';
      _selectedGroup = 'All Groups';
      _selectedStatus = 'All Status';
      _selectedInside = 'All';
      _filterVehicles();
    });
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text('Are you sure you want to delete ${vehicle.vehicleNumber}?'),
          actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
      ),
     );

     if (confirm == true && vehicle.id != null) {
         await _vehicleService.deleteVehicle(vehicle.id!);
         _fetchVehicles();
     }
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
        // ignore error
      }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Stats
    final total = _vehicles.length;
    final authorized = _vehicles.where((v) => v.status == 'Authorized').length;
    final unauthorized = _vehicles.where((v) => v.status == 'Unauthorized' || v.status == 'Blocked' || v.isBlocked).length;
    final inside = _vehicles.where((v) => v.isInside).length;
    final outside = total - inside;
    final twoW = _vehicles.where((v) {
       final t = v.vehicleType.toLowerCase();
       return t.contains('2-wheeler') || t.contains('motorcycle') || t.contains('bike'); 
    }).length;
    final fourW = total - twoW;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Vehicle Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.navBarBlue,
        elevation: 0,
        actions: [
           Padding(
             padding: const EdgeInsets.only(right: 16.0),
             child: ElevatedButton(
               onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                  );
                  if (result == true) _fetchVehicles();
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: const Color(0xFF2962FF),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
               ),
               child: const Text('Add Vehicle'),
             ),
           ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _fetchVehicles,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stats Carousel
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard('Total', total.toString(), Colors.black87),
                    _buildStatCard('Authorized', authorized.toString(), Colors.green),
                    _buildStatCard('Unauthorized', unauthorized.toString(), Colors.red),
                    _buildStatCard('Inside', inside.toString(), Colors.blue),
                    _buildStatCard('Outside', outside.toString(), Colors.black87),
                    _buildStatCard('2W', twoW.toString(), Colors.purple),
                    _buildStatCard('4W', fourW.toString(), Colors.indigo),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Filters Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                   boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                   ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Search
                    const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 45,
                      child: TextField(
                        onChanged: (val) {
                          _searchQuery = val;
                          _filterVehicles();
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search vehicle...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Row 2: Type & Group
                    Row(
                      children: [
                        Expanded(child: _buildCompactDropdown('Type', _selectedType, ['All Types', '2-Wheeler', '4-Wheeler'], (val) {
                              setState(() { _selectedType = val!; _filterVehicles(); });
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCompactDropdown('Group', _selectedGroup, ['All Groups', 'VIP', 'Staff', 'Guest', 'Resident', '3rd Party'], (val) {
                              setState(() { _selectedGroup = val!; _filterVehicles(); });
                        })),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Status & Inside
                    Row(
                      children: [
                        Expanded(child: _buildCompactDropdown('Status', _selectedStatus, ['All Status', 'Authorized', 'Unauthorized'], (val) {
                              setState(() { _selectedStatus = val!; _filterVehicles(); });
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCompactDropdown('Inside', _selectedInside, ['All', 'Inside', 'Outside'], (val) {
                              setState(() { _selectedInside = val!; _filterVehicles(); });
                        })),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Clear Filters Button
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear Filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Vehicle List
              _isLoading 
                 ? const Center(child: CircularProgressIndicator())
                 : _filteredVehicles.isEmpty
                    ? const Center(child: Text('No vehicles found matching filters.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredVehicles.length,
                        itemBuilder: (context, index) {
                           return _buildVehicleCard(_filteredVehicles[index]);
                        },
                      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      width: 100, // Fixed width for carousel
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompactDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 4),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50], // Slight background
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : items.first,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
       ],
     );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
       ),
       child: Column(
         children: [
            Row(
              children: [
                 // Type Icon
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.blue.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(
                      _getVehicleIcon(vehicle.vehicleType),
                      color: Colors.blue,
                      size: 20,
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(vehicle.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(vehicle.ownerName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                     ],
                   ),
                 ),
                 // Status Badge
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                       color: (vehicle.status == 'Authorized') 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                       vehicle.status == 'Authorized' ? 'Authorized' : 'Unauthorized', 
                       style: TextStyle(
                          color: vehicle.status == 'Authorized' ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold
                       )
                    ),
                 ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            // Details Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _buildDetailItem('RFID', vehicle.fastTagId ?? '-'),
                 _buildDetailItem('Group', vehicle.group),
                 _buildDetailItem('Inside', vehicle.isInside ? 'YES' : 'NO', 
                    color: vehicle.isInside ? Colors.blue : null, isBadge: true),
              ],
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                  TextButton(
                     onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddVehicleScreen(vehicleToEdit: vehicle)))
                           .then((val) { if(val == true) _fetchVehicles(); });
                     },
                     child: const Text('Edit'),
                  ),
                  TextButton(
                     onPressed: () { /* Implement Block */ },
                     child: const Text('Block', style: TextStyle(color: Colors.orange)),
                  ),
                  TextButton(
                     onPressed: () => _deleteVehicle(vehicle),
                     child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
               ],
            )
         ],
       ),
     );
  }
  
  Widget _buildDetailItem(String label, String value, {Color? color, bool isBadge = false}) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          isBadge 
            ? Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(
                    color: (color ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(value, style: TextStyle(color: color ?? Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
              )
            : Text(value, style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
       ],
     );
  }

  IconData _getVehicleIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('2-wheeler') || t.contains('motorcycle') || t.contains('bike') || t.contains('scooter')) {
      return Icons.two_wheeler;
    }
    return Icons.directions_car;
  }
}
