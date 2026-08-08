class DiscountModel {
  final String id;
  final String title;
  final String code;
  final String type; // 'percentage' or 'fixed_amount'
  final double value;
  final int? maxUsage;
  final int usedCount;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DiscountModel({
    required this.id,
    required this.title,
    required this.code,
    required this.type,
    required this.value,
    this.maxUsage,
    this.usedCount = 0,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] as String,
      title: json['title'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      maxUsage: json['max_usage'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'type': type,
      'value': value,
      'max_usage': maxUsage,
      'used_count': usedCount,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DiscountModel copyWith({
    String? id,
    String? title,
    String? code,
    String? type,
    double? value,
    int? maxUsage,
    int? usedCount,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      maxUsage: maxUsage ?? this.maxUsage,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}