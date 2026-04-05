import 'package:equatable/equatable.dart';
import 'department.dart';

class Position extends Equatable {
  final int id;
  final String code;
  final String title;
  final String? description;
  final int? departmentId;
  final Department? department;
  final int? level;
  final int? salaryMin;
  final int? salaryMax;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Position({
    required this.id,
    this.code = '',
    required this.title,
    this.description,
    this.departmentId,
    this.department,
    this.level,
    this.salaryMin,
    this.salaryMax,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: _toInt(json['id']) ?? 0,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      departmentId: _toInt(json['department_id']),
      department: json['department'] != null
          ? Department.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      level: _toInt(json['level']),
      salaryMin: _toInt(json['salary_min']),
      salaryMax: _toInt(json['salary_max']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'department_id': departmentId,
      'department': department?.toJson(),
      'level': level,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get salaryRange {
    if (salaryMin != null && salaryMax != null) {
      final min = (salaryMin! / 100).toStringAsFixed(0);
      final max = (salaryMax! / 100).toStringAsFixed(0);
      return '\$$min - \$$max';
    }
    return '-';
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
