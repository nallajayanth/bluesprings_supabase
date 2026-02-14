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
  final String? reason;
  final String group; // e.g., VIP, Staff, Guest
  final bool isInside;

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
    this.reason,
    this.group = 'Resident', // Default
    this.isInside = false,
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
      residentType: json['resident_type'] ?? 'Owner',
      blockName: json['block_name'] ?? '',
      parkingSlot: json['parking_slot'] ?? '',
      isBlocked: json['is_blocked'] ?? false,
      reason: json['reason'],
      group: json['group_name'] ?? 'Resident', // Mapping from DB 'group_name'
      isInside: json['is_inside'] ?? false,
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
      'reason': reason,
      'group_name': group,
      'is_inside': isInside,
    };
  }
}
