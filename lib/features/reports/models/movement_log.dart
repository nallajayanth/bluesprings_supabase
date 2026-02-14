
class MovementLog {
  final DateTime dateTime;
  final String vehicleNumber;
  final String fastTagId;
  final String type; // 'Entry' or 'Exit'
  final String status; // 'Authorized' or 'Unauthorized'
  final String vehicleType; // '2-Wheeler', '4-Wheeler'
  final String? gateNumber;

  MovementLog({
    required this.dateTime,
    required this.vehicleNumber,
    required this.fastTagId,
    required this.type,
    required this.status,
    required this.vehicleType,
    this.gateNumber,
  });
}
