import 'package:equatable/equatable.dart';
import 'department.dart';
import 'position.dart';

class Employee extends Equatable {
  final int id;
  final String? employeeNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankRoutingNumber;
  final int? departmentId;
  final Department? department;
  final int? positionId;
  final Position? position;
  final DateTime? hireDate;
  final int? managerId;
  final Employee? manager;
  final List<Employee>? subordinates;
  final String? status;
  final DateTime? terminationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    this.employeeNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.bankAccountNumber,
    this.bankName,
    this.bankRoutingNumber,
    this.departmentId,
    this.department,
    this.positionId,
    this.position,
    this.hireDate,
    this.managerId,
    this.manager,
    this.subordinates,
    this.status,
    this.terminationDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: _toInt(json['id']) ?? 0,
      employeeNumber: json['employee_number'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: _parseDate(json['date_of_birth']),
      gender: json['gender'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactRelation: json['emergency_contact_relation'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      bankRoutingNumber: json['bank_routing_number'] as String?,
      departmentId: _toInt(json['department_id']),
      department: json['department'] != null
          ? Department.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      positionId: _toInt(json['position_id']),
      position: json['position'] != null
          ? Position.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      hireDate: _parseDate(json['hire_date']),
      managerId: _toInt(json['manager_id']),
      manager: json['manager'] != null
          ? Employee.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      subordinates: json['subordinates'] is List
          ? (json['subordinates'] as List)
                .map((e) => Employee.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      status: json['status'] as String?,
      terminationDate: _parseDate(json['termination_date']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_number': employeeNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'bank_routing_number': bankRoutingNumber,
      'department_id': departmentId,
      'department': department?.toJson(),
      'position_id': positionId,
      'position': position?.toJson(),
      'hire_date': hireDate?.toIso8601String(),
      'manager_id': managerId,
      'manager': manager?.toJson(),
      'subordinates': subordinates?.map((e) => e.toJson()).toList(),
      'status': status,
      'termination_date': terminationDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
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
