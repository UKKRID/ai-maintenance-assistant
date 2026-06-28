import 'package:flutter_test/flutter_test.dart';
import 'package:ai_maintenance_assistant/data/models/pm_task_model.dart';

void main() {
  group('PMTaskModel', () {
    test('should parse from JSON correctly', () {
      final json = {
        'pm_id': 'test-123',
        'machine_id': 'machine-001',
        'machine_name': 'Motor Pump A',
        'assigned_to': 'user-001',
        'assigned_name': 'Somchai',
        'title': 'Monthly Oil Change',
        'description': 'Change engine oil',
        'scheduled_date': '2026-07-01',
        'completed_date': null,
        'status': 'scheduled',
        'notes': null,
        'checklist': [
          {
            'checklist_id': 'cl-1',
            'item_name': 'Check oil',
            'is_required': true,
            'is_completed': false,
            'sort_order': 1,
          }
        ],
        'checklist_progress': {'total': 1, 'completed': 0, 'percentage': 0},
        'created_at': '2026-06-28T10:00:00Z',
        'updated_at': '2026-06-28T10:00:00Z',
      };

      final task = PMTaskModel.fromJson(json);

      expect(task.pmId, 'test-123');
      expect(task.title, 'Monthly Oil Change');
      expect(task.status, 'scheduled');
      expect(task.checklist.length, 1);
      expect(task.checklistTotal, 1);
      expect(task.checklistCompleted, 0);
    });

    test('should return correct status label', () {
      final task = PMTaskModel(
        pmId: '1',
        machineId: 'm1',
        title: 'Test',
        scheduledDate: '2026-07-01',
        status: 'in_progress',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.statusLabel, 'In Progress');
    });

    test('should calculate checklist progress', () {
      final task = PMTaskModel(
        pmId: '1',
        machineId: 'm1',
        title: 'Test',
        scheduledDate: '2026-07-01',
        status: 'scheduled',
        checklist: [
          ChecklistItem(checklistId: '1', itemName: 'Item 1', isRequired: true, isCompleted: true, sortOrder: 1),
          ChecklistItem(checklistId: '2', itemName: 'Item 2', isRequired: true, isCompleted: false, sortOrder: 2),
        ],
        checklistProgress: {'total': 2, 'completed': 1, 'percentage': 50},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.checklistTotal, 2);
      expect(task.checklistCompleted, 1);
      expect(task.checklistPercentage, 50);
    });
  });
}
