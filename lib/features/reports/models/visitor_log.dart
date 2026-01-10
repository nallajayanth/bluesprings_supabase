
class VisitorLog {
  final String vehicleNumber;
  final String fastTagId;
  final DateTime entryTime;
  final DateTime? exitTime; // Null if still inside

  VisitorLog({
    required this.vehicleNumber,
    required this.fastTagId,
    required this.entryTime,
    this.exitTime,
  });

  String get duration {
    if (exitTime == null) return '-';
    
    final diff = exitTime!.difference(entryTime);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    String result = '';
    if (days > 0) result += '${days}D ';
    if (hours > 0) result += '${hours}H ';
    result += '${minutes}M';
    
    return result.trim();
  }
}
