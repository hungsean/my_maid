import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  final int batteryLevel;

  const BatteryWidget({
    super.key,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                        color: _getBatteryColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
      ],
    );
  }

  Color _getBatteryColor() {
    if (batteryLevel > 50) {
      return Colors.green;
    } else if (batteryLevel > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
