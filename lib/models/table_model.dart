enum TableStatus {
  free,
  occupied,
  reserved,
}

extension TableStatusX on TableStatus {
  String get name {
    switch (this) {
      case TableStatus.free: return 'free';
      case TableStatus.occupied: return 'occupied';
      case TableStatus.reserved: return 'reserved';
    }
  }

  static TableStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'occupied': return TableStatus.occupied;
      case 'reserved': return TableStatus.reserved;
      case 'free':
      default:
        return TableStatus.free;
    }
  }
}

class TableModel {
  final String id;
  final String tableNumber;
  final int capacity;
  final TableStatus status;
  final String? currentOrderId;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.status = TableStatus.free,
    this.currentOrderId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String,
      tableNumber: json['table_number'] as String,
      capacity: json['capacity'] as int? ?? 2,
      status: TableStatusX.fromString(json['status'] as String?),
      currentOrderId: json['current_order_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status.name,
      'current_order_id': currentOrderId,
    };
  }

  TableModel copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    TableStatus? status,
    String? currentOrderId,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}