
class StatData {
  final String label;
  final String value;
  final String iconPath; // Using Asset path or IconData could be used if strictly Icon
  // For now using IconData for simplicity as we might not have all assets
  final int color; 

  StatData({required this.label, required this.value, required this.iconPath, required this.color});
}

class WeeklyData {
  final String day;
  final int entry2W;
  final int entry4W;
  final int exit2W;
  final int exit4W;

  WeeklyData({
    required this.day, 
    this.entry2W = 0, 
    this.entry4W = 0, 
    this.exit2W = 0, 
    this.exit4W = 0,
  });

  int get entries => entry2W + entry4W;
  int get exits => exit2W + exit4W;
}

class ActivityLog {
  final String time;
  final String date;
  final String vehicleNo;
  final String type; // '2W' or '4W'
  final bool isEntry; // true for ENTRY, false for EXIT
  final String status; // 'Valid' or 'Invalid'

  ActivityLog({
    required this.time, 
    required this.date,
    required this.vehicleNo, 
    required this.type,
    required this.isEntry,
    required this.status,
  });
}

class RegisteredVehicle {
  final String vehicleNo;
  final String owner;
  final String type;
  final String flat;
  final String status;
  final String date;

  RegisteredVehicle({
    required this.vehicleNo,
    required this.owner,
    required this.type,
    required this.flat,
    required this.status,
    required this.date,
  });
}
