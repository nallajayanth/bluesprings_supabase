class VisitorRequest {
  final String id;
  final String residentName;
  final String block;
  final String flatNumber;
  final int visitorCount;
  final String purpose;
  final String vehicleNumber;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime timestamp;

  VisitorRequest({
    required this.id,
    required this.residentName,
    required this.block,
    required this.flatNumber,
    required this.visitorCount,
    required this.purpose,
    required this.vehicleNumber,
    required this.status,
    required this.timestamp,
  });

  factory VisitorRequest.fromJson(Map<String, dynamic> json) {
    return VisitorRequest(
      id: json['id'] as String,
      residentName: json['residentName'] as String,
      block: json['block'] as String,
      flatNumber: json['flatNumber'] as String,
      visitorCount: json['visitorCount'] as int,
      purpose: json['purpose'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
