import 'package:flutter/material.dart';
import '../../../data/models/ai_analysis_model.dart';

class CauseCard extends StatelessWidget {
  final CauseResponse cause;
  final int rank;

  const CauseCard({
    super.key,
    required this.cause,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(cause.severity),
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                cause.cause,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildConfidenceBadge(),
          ],
        ),
        subtitle: Row(
          children: [
            _buildSeverityBadge(),
            const SizedBox(width: 8),
            Text(
              '${cause.solution.estimatedTimeLabel} • ${cause.solution.estimatedCostLabel}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                _buildSection('Description', cause.description),

                // Solution Steps
                _buildSection('Solution Steps', ''),
                ...cause.solution.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key + 1}. '),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Spare Parts
                if (cause.spareParts.isNotEmpty) ...[
                  _buildSection('Required Parts', ''),
                  ...cause.spareParts.map((part) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${part.partName} (${part.partNumber})')),
                          Text('x${part.quantity}'),
                          const SizedBox(width: 8),
                          Text('฿${part.unitPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 12),

                // Prevention
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prevention:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(cause.prevention),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(content),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildConfidenceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getConfidenceColor(cause.confidence).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getConfidenceColor(cause.confidence)),
      ),
      child: Text(
        '${cause.confidence.toStringAsFixed(0)}%',
        style: TextStyle(
          color: _getConfidenceColor(cause.confidence),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getSeverityColor(cause.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        cause.severityLabel,
        style: TextStyle(
          color: _getSeverityColor(cause.severity),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 70) return Colors.green;
    if (confidence >= 40) return Colors.orange;
    return Colors.red;
  }
}
