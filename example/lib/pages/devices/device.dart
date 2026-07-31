enum DeviceStatus {
  online,
  offline,
  fault;

  String get label => switch (this) {
    DeviceStatus.online => '在线',
    DeviceStatus.offline => '离线',
    DeviceStatus.fault => '故障',
  };

  bool get isOnline => this == DeviceStatus.online;
}

final class Device {
  const Device({
    required this.id,
    required this.name,
    required this.sn,
    required this.status,
    required this.resolution,
    this.customerName,
    this.location,
    this.locationTags = const [],
    this.region,
    this.address,
    this.floor,
    this.mediaPosition,
    this.dimensions,
    this.operatingHours,
    this.totalUptime,
    this.ip,
    this.lastSeenAt,
    this.controlId,
    this.createdAt,
    this.onlineDuration,
    this.voltage,
    this.power,
    this.os,
    this.connection,
    this.temperature,
    this.brightness,
    this.aqi,
    this.co2,
    this.humidity,
    this.managers = const [],
  });

  final int id;
  final String name;
  final String sn;
  final DeviceStatus status;
  final String resolution;
  final String? customerName;
  final String? location;
  final List<String> locationTags;
  final String? region;
  final String? address;
  final String? floor;
  final String? mediaPosition;
  final String? dimensions;
  final String? operatingHours;
  final String? totalUptime;
  final String? ip;
  final String? lastSeenAt;
  final String? controlId;
  final String? createdAt;
  final String? onlineDuration;
  final String? voltage;
  final String? power;
  final String? os;
  final String? connection;
  final String? temperature;
  final String? brightness;
  final String? aqi;
  final String? co2;
  final String? humidity;
  final List<String> managers;
}
