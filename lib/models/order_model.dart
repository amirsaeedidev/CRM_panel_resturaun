class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String orderType; // 'delivery' or 'pickup'
  final String status;
  final double totalAmount;
  final int? estimatedReadyMinutes;
  final String? adminNote;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    this.estimatedReadyMinutes,
    this.adminNote,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Unknown',
      customerPhone: json['customer_phone'] as String? ?? '',
      orderType: json['order_type'] as String? ?? 'delivery',
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      estimatedReadyMinutes: json['estimated_ready_minutes'] as int?,
      adminNote: json['admin_note'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      items: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'order_type': orderType,
      'status': status,
      'total_amount': totalAmount,
      'estimated_ready_minutes': estimatedReadyMinutes,
      'admin_note': adminNote,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'order_items': items.map((e) => e.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerPhone,
    String? orderType,
    String? status,
    double? totalAmount,
    int? estimatedReadyMinutes,
    String? adminNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      estimatedReadyMinutes: estimatedReadyMinutes ?? this.estimatedReadyMinutes,
      adminNote: adminNote ?? this.adminNote,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
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