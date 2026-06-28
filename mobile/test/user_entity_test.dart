import 'package:flutter_test/flutter_test.dart';
import 'package:ai_maintenance_assistant/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should parse from JSON correctly', () {
      final json = {
        'user_id': 'test-123',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'username': 'testuser',
        'phone': '0812345678',
        'role': 'technician',
        'avatar_url': null,
        'created_at': '2026-06-28T10:00:00Z'
      };

      final user = UserEntity.fromJson(json);

      expect(user.userId, 'test-123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.username, 'testuser');
      expect(user.phone, '0812345678');
      expect(user.role, 'technician');
      expect(user.avatarUrl, null);
    });

    test('should serialize to JSON correctly', () {
      final user = UserEntity(
        userId: 'test-123',
        email: 'test@example.com',
        fullName: 'Test User',
        username: 'testuser',
        phone: '0812345678',
        role: 'technician',
        avatarUrl: null,
        createdAt: DateTime(2026, 6, 28),
      );

      final json = user.toJson();

      expect(json['user_id'], 'test-123');
      expect(json['email'], 'test@example.com');
      expect(json['full_name'], 'Test User');
      expect(json['username'], 'testuser');
      expect(json['role'], 'technician');
    });
  });
}
