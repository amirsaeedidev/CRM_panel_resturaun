enum ReservationStatus {
  pending,
  confirmed,
  seated,
  cancelled,
}

extension ReservationStatusX on ReservationStatus {
  String get name {
    switch (this) {
      case ReservationStatus.pending: return 'pending';
      case ReservationStatus.confirmed: return 'confirmed';
      case ReservationStatus.seated: return 'seated';
      case ReservationStatus.cancelled: return 'cancelled';
    }
  }

  static ReservationStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed': return ReservationStatus.confirmed;
      case 'seated': return ReservationStatus.seated;
      case 'cancelled': return ReservationStatus.cancelled;
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }
}

class ReservationModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final String time;
  final int partySize;
  final String tableNumber;
  final String? note;
  final ReservationStatus status;

  ReservationModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.time,
    required this.partySize,
    required this.tableNumber,
    this.note,
    this.status = ReservationStatus.pending,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      partySize: json['party_size'] as int? ?? 1,
      tableNumber: json['table_number'] as String,
      note: json['note'] as String?,
      status: ReservationStatusX.fromString(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'date': date.toIso8601String(),
      'time': time,
      'party_size': partySize,
      'table_number': tableNumber,
      'note': note,
      'status': status.name,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    DateTime? date,
    String? time,
    int? partySize,
    String? tableNumber,
    String? note,
    ReservationStatus? status,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      time: time ?? this.time,
      partySize: partySize ?? this.partySize,
      tableNumber: tableNumber ?? this.tableNumber,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}