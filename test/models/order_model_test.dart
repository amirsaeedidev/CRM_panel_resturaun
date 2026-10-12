import 'package:flutter_test/flutter_test.dart';
import 'package:crm_panel/models/order_model.dart';

void main() {
group('OrderModel', () {
test('fromJson parses valid complete JSON correctly', () {
final json = {
'id': '123e4567-e89b-12d3-a456-426614174000',
'user_id': 'user-uuid-123',
'customer_name': 'علی رضایی',
'customer_phone': '09123456789',
'order_type': 'delivery',
'status': 'pending',
'total_amount': 150000.0,
'estimated_ready_minutes': 30,
'admin_note': 'بدون پیاز',
'completed_at': '2023-10-01T12:30:00Z',
'created_at': '2023-10-01T12:00:00Z',
'updated_at': '2023-10-01T12:15:00Z',
'order_items': [
{'name': 'پیتزا', 'quantity': 2, 'price': 50000.0, 'note': 'تک‌خوب'}
]
};

final order = OrderModel.fromJson(json);

expect(order.id, '123e4567-e89b-12d3-a456-426614174000');
expect(order.userId, 'user-uuid-123');
expect(order.customerName, 'علی رضایی');
expect(order.customerPhone, '09123456789');
expect(order.orderType, 'delivery');
expect(order.status, 'pending');
expect(order.totalAmount, 150000.0);
expect(order.estimatedReadyMinutes, 30);
expect(order.adminNote, 'بدون پیاز');
expect(order.completedAt, DateTime.parse('2023-10-01T12:30:00Z'));
expect(order.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
expect(order.updatedAt, DateTime.parse('2023-10-01T12:15:00Z'));

expect(order.items.length, 1);
expect(order.items.first.name, 'پیتزا');
expect(order.items.first.quantity, 2);
expect(order.items.first.price, 50000.0);
expect(order.items.first.note, 'تک‌خوب');
});

test('fromJson handles null/missing optional fields gracefully', () {
final json = {
'id': '123e4567-e89b-12d3-a456-426614174000',
'created_at': '2023-10-01T12:00:00Z',
// Missing user_id, customer_name, phone, etc.
};

final order = OrderModel.fromJson(json);

expect(order.userId, '');
expect(order.customerName, 'Unknown');
expect(order.customerPhone, '');
expect(order.orderType, 'delivery');
expect(order.status, 'pending');
expect(order.totalAmount, 0.0);
expect(order.estimatedReadyMinutes, isNull);
expect(order.adminNote, isNull);
expect(order.completedAt, isNull);
expect(order.updatedAt, isNull);
expect(order.items, isEmpty);
});

test('toJson produces correct map structure', () {
final order = OrderModel(
id: 'order-123',
userId: 'user-123',
customerName: 'Test User',
customerPhone: '1234567890',
orderType: 'pickup',
status: 'completed',
totalAmount: 50000.0,
estimatedReadyMinutes: 15,
adminNote: 'Test note',
completedAt: DateTime.parse('2023-10-01T12:30:00Z'),
createdAt: DateTime.parse('2023-10-01T12:00:00Z'),
updatedAt: DateTime.parse('2023-10-01T12:15:00Z'),
items: [OrderItem(name: 'Burger', quantity: 1, price: 50000.0)],
);

final json = order.toJson();

expect(json['id'], 'order-123');
expect(json['user_id'], 'user-123');
expect(json['customer_name'], 'Test User');
expect(json['order_type'], 'pickup');
expect(json['status'], 'completed');
expect(json['total_amount'], 50000.0);
expect(json['estimated_ready_minutes'], 15);
expect(json['admin_note'], 'Test note');
expect(json['order_items'], isA<List>());
expect((json['order_items'] as List).first['name'], 'Burger');
});

test('copyWith creates a new instance with updated fields', () {
final original = OrderModel(
id: 'order-123',
userId: 'user-123',
customerName: 'Test User',
customerPhone: '1234567890',
orderType: 'pickup',
status: 'pending',
totalAmount: 50000.0,
createdAt: DateTime.parse('2023-10-01T12:00:00Z'),
items: [],
);

final updated = original.copyWith(status: 'preparing', estimatedReadyMinutes: 20);

expect(updated.id, original.id);
expect(updated.customerName, original.customerName);
expect(updated.status, 'preparing');
expect(updated.estimatedReadyMinutes, 20);
expect(original.status, 'pending'); // Original unchanged
});
});
}