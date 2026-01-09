class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String ownerName;
  final String vehicleType;
  final String flatNumber;
  final String? fastTagId; // Optional as per UI ("Optional - for automatic...")
  final String status;
  final String residentType;
  final String blockName;
  final String parkingSlot;
  final bool isBlocked;

  Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.ownerName,
    required this.vehicleType,
    required this.flatNumber,
    this.fastTagId,
    required this.status,
    required this.residentType,
    required this.blockName,
    required this.parkingSlot,
    this.isBlocked = false,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
      ownerName: json['owner_name'],
      vehicleType: json['vehicle_type'],
      flatNumber: json['flat_number'],
      fastTagId: json['fasttag_id'],
      status: json['status'],
      residentType: json['resident_type'] ?? 'Owner', // Default if missing
      blockName: json['block_name'] ?? '',
      parkingSlot: json['parking_slot'] ?? '',
      isBlocked: json['is_blocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_number': vehicleNumber,
      'owner_name': ownerName,
      'vehicle_type': vehicleType,
      'flat_number': flatNumber,
      'fasttag_id': fastTagId,
      'status': status,
      'resident_type': residentType,
      'block_name': blockName,
      'parking_slot': parkingSlot,
      'is_blocked': isBlocked,
    };
  }
}
