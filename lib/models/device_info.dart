/// Device information for network sync
class DeviceInfo {
  /// Unique device identifier (UUID)
  final String deviceId;

  /// User-defined device name
  final String deviceName;

  /// Last time the device was seen online
  final DateTime lastSeen;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.lastSeen,
  });

  /// Create DeviceInfo from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  /// Convert DeviceInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  DeviceInfo copyWith({
    String? deviceId,
    String? deviceName,
    DateTime? lastSeen,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, deviceName: $deviceName, lastSeen: $lastSeen)';
  }
}
