import 'package:equatable/equatable.dart';

class LeaveType extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int defaultDays;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveType({
    required this.id,
    required this.name,
    this.description,
    this.defaultDays = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      defaultDays: _toInt(json['default_days']) ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'default_days': defaultDays,
      'is_active': isActive,
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

class LeaveBalance extends Equatable {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final int totalDays;
  final int usedDays;
  final LeaveType? leaveType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.totalDays,
    required this.usedDays,
    this.leaveType,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: _toInt(json['id']) ?? 0,
      employeeId: _toInt(json['employee_id']) ?? 0,
      leaveTypeId: _toInt(json['leave_type_id']) ?? 0,
      totalDays: _toInt(json['total_days']) ?? 0,
      usedDays: _toInt(json['used_days']) ?? 0,
      leaveType: json['leave_type'] != null
          ? LeaveType.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'total_days': totalDays,
      'used_days': usedDays,
      'leave_type': leaveType?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  int get remainingDays => totalDays - usedDays;

  double get usagePercent {
    if (totalDays == 0) return 0;
    return (usedDays / totalDays) * 100;
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

class LeaveRequest extends Equatable {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String? status;
  final int? totalDaysRequested;
  final int? reviewerId;
  final String? reviewerNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status,
    this.totalDaysRequested,
    this.reviewerId,
    this.reviewerNote,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: _toInt(json['id']) ?? 0,
      employeeId: _toInt(json['employee_id']) ?? 0,
      leaveTypeId: _toInt(json['leave_type_id']) ?? 0,
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date']) ?? DateTime.now(),
      reason: json['reason'] as String?,
      status: json['status'] as String?,
      totalDaysRequested: _toInt(json['total_days_requested']),
      reviewerId: _toInt(json['reviewer_id']),
      reviewerNote: json['reviewer_note'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'total_days_requested': totalDaysRequested,
      'reviewer_id': reviewerId,
      'reviewer_note': reviewerNote,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

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
