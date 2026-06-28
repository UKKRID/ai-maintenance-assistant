import 'package:flutter/material.dart';
import '../../../data/models/ai_analysis_model.dart';
import '../../widgets/ai/cause_card.dart';

class AiResultPage extends StatelessWidget {
  final AIAnalysisResponse analysis;

  const AiResultPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Result'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analysis Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.precision_manufacturing, color: Color(0xFF1E40AF)),
                        const SizedBox(width: 8),
                        Text(
                          'Machine: ${analysis.machineId}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Analyzed: ${_formatDateTime(analysis.createdAt)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${analysis.processingTime}ms',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Urgency Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getUrgencyColor(analysis.urgency).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getUrgencyColor(analysis.urgency)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber, size: 16, color: _getUrgencyColor(analysis.urgency)),
                  const SizedBox(width: 4),
                  Text(
                    'Urgency: ${analysis.urgencyLabel}',
                    style: TextStyle(
                      color: _getUrgencyColor(analysis.urgency),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary
            if (analysis.summary.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(analysis.summary),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Causes
            const Text(
              '🔍 Possible Causes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (analysis.causes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No causes identified'),
                ),
              )
            else
              ...analysis.causes.asMap().entries.map((entry) {
                final index = entry.key;
                final cause = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CauseCard(
                    cause: cause,
                    rank: index + 1,
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to create report
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Create Report'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to spare parts
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('View Parts'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feedback Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Was this analysis helpful?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _submitFeedback(context, 'helpful'),
                            child: const Text('👍 Helpful'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _submitFeedback(context, 'partially_helpful'),
                            child: const Text('🤔 Partial'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _submitFeedback(context, 'not_helpful'),
                            child: const Text('👎 Not Helpful'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'immediate':
        return Colors.red;
      case 'within_hour':
        return Colors.orange;
      case 'within_day':
        return Colors.yellow[700]!;
      case 'can_wait':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _submitFeedback(BuildContext context, String feedback) {
    // TODO: Implement feedback submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback submitted: $feedback'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
