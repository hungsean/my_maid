import 'dart:async';
import 'package:flutter/material.dart';
import '../services/battery_service.dart';

class BatteryWidget extends StatefulWidget {
  const BatteryWidget({super.key});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget> {
  final BatteryService _batteryService = BatteryService();
  BatteryDisplayInfo? _batteryInfo;
  bool _isLoading = true;
  Timer? _updateTimer;
  StreamSubscription? _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _loadBatteryInfo();
    _listenToBatteryChanges();
    _startPeriodicUpdate();
  }

  Future<void> _loadBatteryInfo() async {
    try {
      final info = await _batteryService.getBatteryDisplayInfo();
      if (mounted) {
        setState(() {
          _batteryInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToBatteryChanges() {
    _batteryStateSubscription =
        _batteryService.onBatteryStateChanged.listen((state) {
      _loadBatteryInfo();
    });
  }

  /// Start periodic battery level update
  /// This is especially important for iOS where battery level changes
  /// don't always trigger state change events
  void _startPeriodicUpdate() {
    // Update every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadBatteryInfo();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_batteryInfo == null) {
      return const Center(
        child: Text(
          'Unable to get battery info',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final batteryLevel = _batteryInfo!.level;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Battery status text
        Text(
          _batteryInfo!.description,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
        // Battery icon (body + head combined in a Row)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Battery body
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Battery level fill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 200 * (batteryLevel / 100),
                      decoration: BoxDecoration(
                        color: _getBatteryColor(batteryLevel),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Charging indicator
                  if (_batteryInfo!.isCharging)
                    const Center(
                      child: Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  // Plug indicator for full/connected states
                  if (_batteryInfo!.shouldShowPlugIcon)
                    const Center(
                      child: Icon(
                        Icons.power,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ),
            // Battery head
            Container(
              width: 10,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // Battery percentage text
        Text(
          '$batteryLevel%',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Low battery warning
        if (_batteryInfo!.isLowBattery && !_batteryInfo!.isPluggedIn)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _batteryInfo!.isCriticalBattery ? '⚠️ 電量極低！' : '⚠️ 電量偏低',
              style: TextStyle(
                fontSize: 18,
                color: _batteryInfo!.isCriticalBattery
                    ? Colors.red
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 50) {
      return Colors.green;
    } else if (level > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
