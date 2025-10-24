import 'package:battery_plus/battery_plus.dart';

/// Service class for monitoring device battery status
class BatteryService {
  final Battery _battery = Battery();

  /// Get current battery level (0-100)
  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  /// Get current battery state
  Future<BatteryState> getBatteryState() async {
    return await _battery.batteryState;
  }

  /// Check if device is in battery save mode
  Future<bool> isInBatterySaveMode() async {
    return await _battery.isInBatterySaveMode;
  }

  /// Stream of battery state changes
  Stream<BatteryState> get onBatteryStateChanged =>
      _battery.onBatteryStateChanged;

  /// Check if device is charging (includes all charging states)
  Future<bool> isCharging() async {
    final state = await getBatteryState();
    return state == BatteryState.charging;
  }

  /// Check if device is plugged in (charging or connected but not charging)
  Future<bool> isPluggedIn() async {
    final state = await getBatteryState();
    // Note: connectedNotCharging is removed because on some Android devices
    // it's incorrectly reported when the device is actually unplugged
    return state == BatteryState.charging ||
        state == BatteryState.full;
  }

  /// Get battery status description in Chinese
  Future<String> getBatteryStatusDescription() async {
    final state = await getBatteryState();
    switch (state) {
      case BatteryState.charging:
        return '充電中';
      case BatteryState.discharging:
        return '使用電池';
      case BatteryState.full:
        return '電池已充飽';
      case BatteryState.connectedNotCharging:
        return '使用電池';
      case BatteryState.unknown:
        return '無法取得電池資訊';
    }
  }

  /// Get battery icon based on level and state
  Future<BatteryDisplayInfo> getBatteryDisplayInfo() async {
    final level = await getBatteryLevel();
    final state = await getBatteryState();

    return BatteryDisplayInfo(
      level: level,
      state: state,
      isPluggedIn: await isPluggedIn(),
    );
  }
}

/// Battery display information
/// This class encapsulates all battery information needed for UI display
/// without exposing the underlying BatteryState enum from battery_plus
class BatteryDisplayInfo {
  final int level;
  final BatteryState _state;
  final bool isPluggedIn;

  BatteryDisplayInfo({
    required this.level,
    required BatteryState state,
    required this.isPluggedIn,
  }) : _state = state;

  /// Get description text
  String get description {
    switch (_state) {
      case BatteryState.charging:
        return '充電中';
      case BatteryState.discharging:
        return '使用電池';
      case BatteryState.full:
        return '電池已充飽';
      case BatteryState.connectedNotCharging:
        return '使用電池';
      case BatteryState.unknown:
        return '無法取得電池資訊';
    }
  }

  /// Check if battery is in low state (below 20%)
  bool get isLowBattery => level < 20;

  /// Check if battery is in critical state (below 10%)
  bool get isCriticalBattery => level < 10;

  /// Check if device is currently charging
  bool get isCharging => _state == BatteryState.charging;

  /// Check if device should show plug icon (plugged in but not charging)
  bool get shouldShowPlugIcon => isPluggedIn && !isCharging;
}
