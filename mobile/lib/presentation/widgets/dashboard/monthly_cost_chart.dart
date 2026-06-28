import 'package:flutter/material.dart';

class MonthlyCostChart extends StatelessWidget {
  const MonthlyCostChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'month': 'Jan', 'cost': 5000.0},
      {'month': 'Feb', 'cost': 8000.0},
      {'month': 'Mar', 'cost': 3000.0},
      {'month': 'Apr', 'cost': 12000.0},
      {'month': 'May', 'cost': 6000.0},
      {'month': 'Jun', 'cost': 9000.0},
    ];

    final maxCost = data.map((d) => d['cost'] as double).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Cost',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final cost = item['cost'] as double;
                  final height = (cost / maxCost) * 120;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '฿${(cost / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E40AF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['month'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
