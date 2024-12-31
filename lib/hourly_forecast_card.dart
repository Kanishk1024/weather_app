import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  const HourlyForecastCard(
      {super.key, required this.time, required this.temp, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              temp,
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
