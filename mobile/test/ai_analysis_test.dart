import 'package:flutter_test/flutter_test.dart';
import 'package:ai_maintenance_assistant/domain/entities/ai_analysis.dart';

void main() {
  group('AIAnalysis Entity', () {
    test('should parse from JSON correctly', () {
      final json = {
        'analysis_id': 'test-123',
        'machine_id': 'machine-001',
        'input_text': 'Motor noise',
        'confidence': 85.5,
        'causes': [
          {
            'cause': 'Bearing Wear',
            'confidence': 85.5,
            'description': 'Bearing is worn out',
            'severity': 'high',
            'solution': {
              'steps': ['Step 1', 'Step 2'],
              'estimated_time_minutes': 120,
              'estimated_cost': 2500.0,
              'difficulty': 'medium'
            },
            'spare_parts': [
              {
                'part_name': 'Bearing',
                'part_number': 'BRG-001',
                'quantity': 2,
                'unit_price': 850.0
              }
            ],
            'prevention': 'Lubricate regularly'
          }
        ],
        'summary': 'Bearing needs replacement',
        'urgency': 'within_hour',
        'model_version': 'gpt-4-vision',
        'processing_time': 3500,
        'created_at': '2026-06-28T10:00:00Z'
      };

      final analysis = AIAnalysis.fromJson(json);

      expect(analysis.analysisId, 'test-123');
      expect(analysis.machineId, 'machine-001');
      expect(analysis.confidence, 85.5);
      expect(analysis.causes.length, 1);
      expect(analysis.causes[0].cause, 'Bearing Wear');
      expect(analysis.causes[0].solution.estimatedTimeLabel, '2 ชั่วโมง');
    });

    test('should calculate estimated time label correctly', () {
      final solution = Solution(
        steps: ['Step 1'],
        estimatedTimeMinutes: 90,
        estimatedCost: 1000,
        difficulty: 'medium',
      );

      expect(solution.estimatedTimeLabel, '1 ชม. 30 นาที');
    });

    test('should calculate total price correctly', () {
      final sparePart = SparePart(
        partName: 'Bearing',
        partNumber: 'BRG-001',
        quantity: 3,
        unitPrice: 850.0,
      );

      expect(sparePart.totalPrice, 2550.0);
      expect(sparePart.totalPriceLabel, '฿2550');
    });
  });
}
