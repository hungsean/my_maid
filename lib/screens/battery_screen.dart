import 'package:flutter/material.dart';
import '../widgets/battery_widget.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: BatteryWidget(batteryLevel: 80),
      ),
    );
  }
}
