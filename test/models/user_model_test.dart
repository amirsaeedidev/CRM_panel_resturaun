import 'package:flutter_test/flutter_test.dart';
import 'package:crm_panel/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'first_name': 'علی',
        'last_name': 'رضایی',
        'phone': '09123456789',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role': 'customer',
        'created_at': '2023-10-01T12:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'علی');
      expect(user.lastName, 'رضایی');
      expect(user.phone, '09123456789');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.role, 'customer');
      expect(user.fullName, 'علی رضایی');
      expect(user.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
    });

    test('fromJson handles null/missing optional fields', () {
      final json = {
        'id': 'user-456',
        'email': 'test2@example.com',
        'created_at': '2023-10-02T12:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.role, 'user'); // Default value
      expect(user.fullName, 'test2@example.com'); // Falls back to email
    });

    test('toJson produces correct map', () {
      final user = UserModel(
        id: 'user-789',
        email: 'test3@example.com',
        firstName: 'محمد',
        role: 'admin',
        createdAt: DateTime.parse('2023-10-03T12:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'user-789');
      expect(json['email'], 'test3@example.com');
      expect(json['first_name'], 'محمد');
      expect(json['role'], 'admin');
    });

    test('copyWith updates fields correctly', () {
      final original = UserModel(
        id: 'user-001',
        email: 'orig@example.com',
        role: 'customer',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(role: 'admin');

      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.role, 'admin');
      expect(original.role, 'customer'); // Original unchanged
    });
  });
}