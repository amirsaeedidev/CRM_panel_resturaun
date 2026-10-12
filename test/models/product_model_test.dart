import 'package:flutter_test/flutter_test.dart';
import 'package:crm_panel/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('fromJson parses valid complete JSON correctly', () {
      final json = {
        'id': 'prod-123',
        'name': 'پیتزا پپرونی',
        'description': 'پیتزا با پنیر و پپرونی',
        'price': 120000.0,
        'discounted_price': 99000.0,
        'category_id': 'cat-1',
        'stock': 50,
        'image_url': 'https://example.com/pizza.jpg',
        'status': 'active',
        'is_popular': true,
        'rating': 4.5,
        'review_count': 120,
        'created_at': '2023-10-01T12:00:00Z',
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'prod-123');
      expect(product.name, 'پیتزا پپرونی');
      expect(product.description, 'پیتزا با پنیر و پپرونی');
      expect(product.price, 120000.0);
      expect(product.discountedPrice, 99000.0);
      expect(product.categoryId, 'cat-1');
      expect(product.stock, 50);
      expect(product.imageUrl, 'https://example.com/pizza.jpg');
      expect(product.status, 'active');
      expect(product.isPopular, true);
      expect(product.rating, 4.5);
      expect(product.reviewCount, 120);
      expect(product.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
    });

    test('fromJson handles null/missing optional fields gracefully', () {
      final json = {
        'id': 'prod-456',
        'name': 'برگر',
        'description': '',
        'price': 80000.0,
        'category_id': 'cat-2',
        'stock': 0,
        'image_url': '',
        'status': 'inactive',
        'created_at': '2023-10-02T12:00:00Z',
        // Missing discounted_price, is_popular, rating, review_count
      };

      final product = ProductModel.fromJson(json);

      expect(product.discountedPrice, isNull);
      expect(product.isPopular, false); // Default value
      expect(product.rating, isNull);
      expect(product.reviewCount, isNull);
    });

    test('toJson produces correct map structure', () {
      final product = ProductModel(
        id: 'prod-789',
        name: 'سالاد',
        description: 'سالاد سزار',
        price: 50000.0,
        discountedPrice: 40000.0,
        categoryId: 'cat-3',
        stock: 10,
        imageUrl: 'https://example.com/salad.jpg',
        status: 'active',
        isPopular: false,
        rating: 5.0,
        reviewCount: 5,
        createdAt: DateTime.parse('2023-10-03T12:00:00Z'),
      );

      final json = product.toJson();

      expect(json['id'], 'prod-789');
      expect(json['name'], 'سالاد');
      expect(json['price'], 50000.0);
      expect(json['discounted_price'], 40000.0);
      expect(json['is_popular'], false);
      expect(json['rating'], 5.0);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = ProductModel(
        id: 'prod-001',
        name: 'نوشابه',
        description: 'نوشابه گازدار',
        price: 15000.0,
        categoryId: 'cat-4',
        stock: 100,
        imageUrl: '',
        status: 'active',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(stock: 0, status: 'out_of_stock');

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.stock, 0);
      expect(updated.status, 'out_of_stock');
      expect(original.stock, 100); // Original unchanged
    });
  });
}