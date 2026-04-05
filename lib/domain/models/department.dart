import 'package:equatable/equatable.dart';

class Department extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? headId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Department({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.headId,
    this.createdAt,
    this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      headId: _toInt(json['head_id']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'head_id': headId,
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
