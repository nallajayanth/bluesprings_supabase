
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/unauthorized_vehicle_model.dart';

class UnauthorizedService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'unauthorized_vehicles';

  // Fetch all unauthorized vehicles
  Future<List<UnauthorizedVehicle>> getUnauthorizedVehicles() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .order('unauthorized_date', ascending: false);
      
      return (data as List).map((e) => UnauthorizedVehicle.fromJson(e)).toList();
    } catch (e) {
      // Return empty list if table doesn't exist yet or error occurs
      // ideally we should throw, but for initial dev UI flow we might want to be graceful
      // throwing is better for debugging
      throw Exception('Failed to load unauthorized vehicles: $e');
    }
  }

  // Add a new unauthorized vehicle (for the "Unauthorize New Vehicle" button)
  Future<void> addUnauthorizedVehicle(UnauthorizedVehicle vehicle) async {
    try {
      // Exclude ID from insert as it's auto-generated
      final json = vehicle.toJson();
      await _supabase.from(_tableName).insert(json);
    } catch (e) {
      throw Exception('Failed to add unauthorized vehicle: $e');
    }
  }

  // Update status (e.g. to 'Authorized')
  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'status': newStatus})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
  
  // Delete entry
  Future<void> deleteUnauthorizedVehicle(int id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }
}
