
class MovementLog {
  final DateTime dateTime;
  final String vehicleNumber;
  final String fastTagId;
  final String type; // 'Entry' or 'Exit'
  final String status; // 'Authorized' or 'Unauthorized'

  MovementLog({
    required this.dateTime,
    required this.vehicleNumber,
    required this.fastTagId,
    required this.type,
    required this.status,
  });
}
