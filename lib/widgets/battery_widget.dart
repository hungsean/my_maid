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
        // 電池圖示
        Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // 電量填充
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
        // 電池頭
        Container(
          width: 10,
          height: 30,
          margin: const EdgeInsets.only(left: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // 電量百分比文字
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
