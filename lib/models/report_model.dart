class ReportModel {
  final String id;
  final String type; // e.g., 'sales', 'inventory', 'customers'
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> chartData;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.type,
    required this.summary,
    required this.chartData,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      type: json['type'] as String,
      summary: json['summary'] as Map<String, dynamic>? ?? {},
      chartData: (json['chart_data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'summary': summary,
      'chart_data': chartData,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReportModel copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? summary,
    List<Map<String, dynamic>>? chartData,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      chartData: chartData ?? this.chartData,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}