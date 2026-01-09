
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
  final int entries;
  final int exits;

  WeeklyData({required this.day, required this.entries, required this.exits});
}

class ActivityLog {
  final String time;
  final String vehicleNo;
  final bool isEntry; // true for ENTRY, false for EXIT

  ActivityLog({required this.time, required this.vehicleNo, required this.isEntry});
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
