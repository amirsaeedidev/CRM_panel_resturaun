class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? emoji;
  final String? imageUrl;
  final String? actionUrl;
  final bool isActive;
  final bool isDeleted; // Soft delete flag
  final int displayOrder;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.emoji,
    this.imageUrl,
    this.actionUrl,
    this.isActive = true,
    this.isDeleted = false,
    this.displayOrder = 0,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      emoji: json['emoji'] as String?,
      imageUrl: json['image_url'] as String?,
      actionUrl: json['action_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'emoji': emoji,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'display_order': displayOrder,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? emoji,
    String? imageUrl,
    String? actionUrl,
    bool? isActive,
    bool? isDeleted,
    int? displayOrder,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      displayOrder: displayOrder ?? this.displayOrder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}