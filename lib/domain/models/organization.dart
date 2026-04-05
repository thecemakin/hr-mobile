import 'package:equatable/equatable.dart';

class OrganizationNode extends Equatable {
  final int id;
  final String name;
  final String type;
  final int? parentId;
  final List<OrganizationNode> children;
  final int? employeeId;
  final String? employeeName;
  final String? position;
  final String? department;
  final int? directReportsCount;

  const OrganizationNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.children = const [],
    this.employeeId,
    this.employeeName,
    this.position,
    this.department,
    this.directReportsCount,
  });

  factory OrganizationNode.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString();
    final lastName = json['last_name']?.toString();
    final fullName = firstName != null && lastName != null
        ? '$firstName $lastName'
        : json['name']?.toString() ?? '';

    final jobTitle = json['job_title']?.toString();
    final dept = json['department']?.toString();

    String nodeType = json['type']?.toString() ?? 'unknown';
    if (nodeType == 'unknown') {
      if (json['subordinates'] != null) {
        nodeType = dept?.toLowerCase() == 'management'
            ? 'department'
            : 'position';
      } else {
        nodeType = 'employee';
      }
    }

    dynamic childrenData = json['children'] ?? json['subordinates'];

    return OrganizationNode(
      id: _toInt(json['id']) ?? 0,
      name: fullName,
      type: nodeType,
      parentId: _toInt(json['parent_id']),
      children: childrenData is List
          ? childrenData
                .map(
                  (e) => OrganizationNode.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      employeeId: _toInt(json['employee_id']) ?? _toInt(json['id']),
      employeeName: json['employee_name']?.toString() ?? fullName,
      position: json['position']?.toString() ?? jobTitle,
      department: dept,
      directReportsCount:
          _toInt(json['direct_reports_count']) ??
          (childrenData is List ? childrenData.length : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parent_id': parentId,
      'children': children.map((e) => e.toJson()).toList(),
      'employee_id': employeeId,
      'employee_name': employeeName,
      'position': position,
      'department': department,
      'direct_reports_count': directReportsCount,
    };
  }

  bool get isDepartment => type == 'department';
  bool get isEmployee => type == 'employee';
  bool get isPosition => type == 'position';
  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props => [id];

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is num) return v.toInt();
    return null;
  }
}
