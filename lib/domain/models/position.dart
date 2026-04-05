import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int id;
  final String title;
  final String? description;
  final int? departmentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Position({
    required this.id,
    required this.title,
    this.description,
    this.departmentId,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: _toInt(json['id']) ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      departmentId: _toInt(json['department_id']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'department_id': departmentId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id];

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is num) return v.toInt();
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty || s == '0001-01-01T00:00:00Z') return null;
    return DateTime.tryParse(s);
  }
}
