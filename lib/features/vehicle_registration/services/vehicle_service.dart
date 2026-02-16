import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'vehicle_registration';

  // Fetch all vehicles
  Future<List<Vehicle>> getVehicles() async {
    try {
      print('Fetching vehicles from $_tableName...');
      final data = await _supabase
          .from(_tableName)
          .select()
          .order('id', ascending: false); // Newest first
      
      print('Fetched ${data.length} vehicles.');
      // print('Data: $data'); // Uncomment to see full data
      
      return (data as List).map((e) => Vehicle.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching vehicles: $e');
      throw Exception('Failed to load vehicles: $e');
    }
  }

  // Fetch only unauthorized/blocked vehicles
  Future<List<Vehicle>> getUnauthorizedVehicles() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('is_blocked', true)
          .order('id', ascending: false);
      
      return (data as List).map((e) => Vehicle.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load unauthorized vehicles: $e');
    }
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _supabase.from(_tableName).insert(vehicle.toJson());
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) return;
    try {
      await _supabase
          .from(_tableName)
          .update(vehicle.toJson())
          .eq('id', vehicle.id!);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete a vehicle
  Future<void> deleteVehicle(int id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}
