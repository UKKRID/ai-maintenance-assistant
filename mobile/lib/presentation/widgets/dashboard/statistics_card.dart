import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final int totalMachines;
  final int activeMachines;
  final int totalRepairs;
  final int pendingRepairs;
  final int completedRepairs;
  final int totalPmTasks;
  final int overduePmTasks;
  final double totalCost;

  const StatisticsCard({
    super.key,
    required this.totalMachines,
    required this.activeMachines,
    required this.totalRepairs,
    required this.pendingRepairs,
    required this.completedRepairs,
    required this.totalPmTasks,
    required this.overduePmTasks,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.precision_manufacturing,
                    label: 'Machines',
                    value: '$totalMachines',
                    subtitle: '$activeMachines active',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.build,
                    label: 'Repairs',
                    value: '$totalRepairs',
                    subtitle: '$pendingRepairs pending',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'PM Tasks',
                    value: '$totalPmTasks',
                    subtitle: '$overduePmTasks overdue',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.attach_money,
                    label: 'Total Cost',
                    value: '฿${totalCost.toStringAsFixed(0)}',
                    subtitle: 'This month',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
