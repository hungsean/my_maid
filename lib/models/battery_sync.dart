import 'package:battery_plus/battery_plus.dart';
import 'device_info.dart';

/// Battery synchronization data for network sync
class BatterySync {
  /// Device information
  final DeviceInfo device;

  /// Battery level (0-100)
  final int batteryLevel;

  /// Battery state (charging, discharging, full, etc.)
  final BatteryState state;

  /// Whether the device is plugged in (charging or connected)
  final bool isPluggedIn;

  /// Timestamp when this data was captured
  final DateTime timestamp;

  BatterySync({
    required this.device,
    required this.batteryLevel,
    required this.state,
    required this.isPluggedIn,
    required this.timestamp,
  });

  /// Create BatterySync from JSON
  factory BatterySync.fromJson(Map<String, dynamic> json) {
    return BatterySync(
      device: DeviceInfo.fromJson(json['device'] as Map<String, dynamic>),
      batteryLevel: json['batteryLevel'] as int,
      state: _batteryStateFromString(json['state'] as String),
      isPluggedIn: json['isPluggedIn'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert BatterySync to JSON
  Map<String, dynamic> toJson() {
    return {
      'device': device.toJson(),
      'batteryLevel': batteryLevel,
      'state': _batteryStateToString(state),
      'isPluggedIn': isPluggedIn,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert BatteryState to string for JSON serialization
  static String _batteryStateToString(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'charging';
      case BatteryState.discharging:
        return 'discharging';
      case BatteryState.full:
        return 'full';
      case BatteryState.connectedNotCharging:
        return 'connectedNotCharging';
      case BatteryState.unknown:
        return 'unknown';
    }
  }

  /// Convert string to BatteryState for JSON deserialization
  static BatteryState _batteryStateFromString(String state) {
    switch (state) {
      case 'charging':
        return BatteryState.charging;
      case 'discharging':
        return BatteryState.discharging;
      case 'full':
        return BatteryState.full;
      case 'connectedNotCharging':
        return BatteryState.connectedNotCharging;
      default:
        return BatteryState.unknown;
    }
  }

  /// Create a copy with updated fields
  BatterySync copyWith({
    DeviceInfo? device,
    int? batteryLevel,
    BatteryState? state,
    bool? isPluggedIn,
    DateTime? timestamp,
  }) {
    return BatterySync(
      device: device ?? this.device,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      state: state ?? this.state,
      isPluggedIn: isPluggedIn ?? this.isPluggedIn,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Check if this battery data is recent (within last 5 minutes)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes < 5;
  }

  /// Check if the device is online (last seen within 1 minute)
  bool get isOnline {
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen);
    return difference.inMinutes < 1;
  }

  @override
  String toString() {
    return 'BatterySync(device: ${device.deviceName}, level: $batteryLevel%, state: $state, isPluggedIn: $isPluggedIn, timestamp: $timestamp)';
  }
}
