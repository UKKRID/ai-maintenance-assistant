import 'package:flutter/material.dart';

class PMStatusChart extends StatelessWidget {
  const PMStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'status': 'Scheduled', 'count': 4, 'color': Colors.blue},
      {'status': 'In Progress', 'count': 2, 'color': Colors.orange},
      {'status': 'Completed', 'count': 6, 'color': Colors.green},
      {'status': 'Overdue', 'count': 1, 'color': Colors.red},
    ];

    final total = data.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PM Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie Chart representation
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _PieChartPainter(data: data, total: total),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item['status']} (${item['count']})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int total;

  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -90;

    for (final item in data) {
      final count = item['count'] as int;
      final sweepAngle = (count / total) * 360;

      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle * 3.14159 / 180,
        sweepAngle * 3.14159 / 180,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
