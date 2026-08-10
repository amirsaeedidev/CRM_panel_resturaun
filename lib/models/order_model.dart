class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String orderType; // delivery, dine_in, pickup
  final String? tableNumber;
  final String? shippingAddress;
  final String? postalCode;
  final String? customerNote;
  final int? estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderType,
    this.tableNumber,
    this.shippingAddress,
    this.postalCode,
    this.customerNote,
    this.estimatedDeliveryTime,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String? ?? 'Unknown',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      orderType: json['order_type'] as String? ?? 'delivery',
      tableNumber: json['table_number'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      postalCode: json['postal_code'] as String?,
      customerNote: json['customer_note'] as String?,
      estimatedDeliveryTime: json['estimated_delivery_time'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'order_type': orderType,
      'table_number': tableNumber,
      'shipping_address': shippingAddress,
      'postal_code': postalCode,
      'customer_note': customerNote,
      'estimated_delivery_time': estimatedDeliveryTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    String? orderType,
    String? tableNumber,
    String? shippingAddress,
    String? postalCode,
    String? customerNote,
    int? estimatedDeliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber ?? this.tableNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      postalCode: postalCode ?? this.postalCode,
      customerNote: customerNote ?? this.customerNote,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String? note;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'note': note,
    };
  }
}