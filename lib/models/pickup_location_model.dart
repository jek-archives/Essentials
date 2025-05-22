class PickupLocation {
  final int id;
  final String name;
  final String address;
  final String operatingHours;
  final bool isActive;

  PickupLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.operatingHours,
    required this.isActive,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    return PickupLocation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      operatingHours: json['operating_hours'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'operating_hours': operatingHours,
      'is_active': isActive,
    };
  }
} 