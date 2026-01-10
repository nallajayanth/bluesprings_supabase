
class UnauthorizedVehicle {
  final int? id;
  final String vehicleNumber;
  final DateTime unauthorizedDate;
  final String reason;
  final String status;

  UnauthorizedVehicle({
    this.id,
    required this.vehicleNumber,
    required this.unauthorizedDate,
    required this.reason,
    required this.status,
  });

  factory UnauthorizedVehicle.fromJson(Map<String, dynamic> json) {
    return UnauthorizedVehicle(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
      unauthorizedDate: DateTime.parse(json['unauthorized_date']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Unauthorized',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_number': vehicleNumber,
      'unauthorized_date': unauthorizedDate.toIso8601String(),
      'reason': reason,
      'status': status,
    };
  }
}
