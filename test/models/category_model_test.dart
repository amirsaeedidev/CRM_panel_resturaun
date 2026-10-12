import 'package:flutter_test/flutter_test.dart';
import 'package:crm_panel/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': 'cat-123',
        'name': 'پیتزاها',
        'description': 'انواع پیتزا',
        'image_url': 'https://example.com/cat.jpg',
        'is_active': true,
        'display_order': 1,
        'created_at': '2023-10-01T10:00:00Z',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, 'cat-123');
      expect(category.name, 'پیتزاها');
      expect(category.description, 'انواع پیتزا');
      expect(category.imageUrl, 'https://example.com/cat.jpg');
      expect(category.isActive, true);
      expect(category.displayOrder, 1);
      expect(category.createdAt, DateTime.parse('2023-10-01T10:00:00Z'));
    });

    test('fromJson handles null/missing optional fields', () {
      final json = {
        'id': 'cat-456',
        'name': 'برگرها',
        'created_at': '2023-10-02T10:00:00Z',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.description, isNull);
      expect(category.imageUrl, isNull);
      expect(category.isActive, true); // Default value
      expect(category.displayOrder, 0); // Default value
    });

    test('toJson produces correct map', () {
      final category = CategoryModel(
        id: 'cat-789',
        name: 'نوشیدنی‌ها',
        description: 'سرد و گرم',
        isActive: false,
        displayOrder: 5,
        createdAt: DateTime.parse('2023-10-03T10:00:00Z'),
      );

      final json = category.toJson();

      expect(json['id'], 'cat-789');
      expect(json['name'], 'نوشیدنی‌ها');
      expect(json['is_active'], false);
      expect(json['display_order'], 5);
    });

    test('copyWith updates fields correctly', () {
      final original = CategoryModel(
        id: 'cat-001',
        name: 'دسرها',
        isActive: true,
        displayOrder: 2,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(isActive: false, displayOrder: 10);

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.isActive, false);
      expect(updated.displayOrder, 10);
      expect(original.isActive, true); // Original unchanged
    });
  });
}