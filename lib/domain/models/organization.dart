import 'package:equatable/equatable.dart';

class OrganizationNode extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final OrganizationNode? parent;
  final List<OrganizationNode> children;
  final String? employeeId;
  final String? employeeName;
  final String? position;
  final String? department;
  final int? directReportsCount;

  const OrganizationNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.parent,
    this.children = const [],
    this.employeeId,
    this.employeeName,
    this.position,
    this.department,
    this.directReportsCount,
  });

  factory OrganizationNode.fromJson(Map<String, dynamic> json) {
    // Handle both API formats:
    // Format 1: id, name, type, children (standard)
    // Format 2: id, first_name, last_name, job_title, department, subordinates (employee tree)

    final firstName = json['first_name']?.toString();
    final lastName = json['last_name']?.toString();
    final fullName = firstName != null && lastName != null
        ? '$firstName $lastName'
        : json['name']?.toString() ?? '';

    final jobTitle = json['job_title']?.toString();
    final department = json['department']?.toString();

    // Determine type based on available fields
    String nodeType = json['type']?.toString() ?? 'unknown';
    if (nodeType == 'unknown') {
      // Try to infer type from the data
      if (json['subordinates'] != null) {
        nodeType = department?.toLowerCase() == 'management'
            ? 'department'
            : 'position';
      } else {
        nodeType = 'employee';
      }
    }

    // Handle children - could be 'children' or 'subordinates'
    dynamic childrenData = json['children'] ?? json['subordinates'];

    return OrganizationNode(
      id: json['id']?.toString() ?? '',
      name: fullName,
      type: nodeType,
      parentId: json['parent_id']?.toString(),
      parent: json['parent'] != null
          ? OrganizationNode.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: childrenData != null
          ? (childrenData is List)
                ? childrenData
                      .map(
                        (e) => OrganizationNode.fromJson(
                          e is Map<String, dynamic>
                              ? e
                              : e as Map<String, dynamic>,
                        ),
                      )
                      .toList()
                : []
          : [],
      employeeId: json['employee_id']?.toString() ?? json['id']?.toString(),
      employeeName: json['employee_name']?.toString() ?? fullName,
      position: json['position']?.toString() ?? jobTitle,
      department: json['department']?.toString() ?? department,
      directReportsCount: json['direct_reports_count'] is int
          ? json['direct_reports_count'] as int
          : json['direct_reports_count'] is String
          ? int.tryParse(json['direct_reports_count'] as String)
          : childrenData is List
          ? childrenData.length
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parent_id': parentId,
      'parent': parent?.toJson(),
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
}
