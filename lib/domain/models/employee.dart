import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String? employeeNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final Address? address;
  final EmergencyContact? emergencyContact;
  final BankInfo? bankInfo;
  final Department? department;
  final Position? position;
  final DateTime? hireDate;
  final String? managerId;
  final Employee? manager;
  final String? status;
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
    this.address,
    this.emergencyContact,
    this.bankInfo,
    this.department,
    this.position,
    this.hireDate,
    this.managerId,
    this.manager,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      employeeNumber: json['employee_number']?.toString(),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'].toString())
          : null,
      gender: json['gender'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContact.fromJson(
              json['emergency_contact'] as Map<String, dynamic>,
            )
          : null,
      bankInfo: json['bank_info'] != null
          ? BankInfo.fromJson(json['bank_info'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      position: json['position'] != null
          ? Position.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'].toString())
          : null,
      managerId: json['manager_id']?.toString(),
      manager: json['manager'] != null
          ? Employee.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
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
      'address': address?.toJson(),
      'emergency_contact': emergencyContact?.toJson(),
      'bank_info': bankInfo?.toJson(),
      'department': department?.toJson(),
      'position': position?.toJson(),
      'hire_date': hireDate?.toIso8601String(),
      'manager_id': managerId,
      'manager': manager?.toJson(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? employeeNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    Address? address,
    EmergencyContact? emergencyContact,
    BankInfo? bankInfo,
    Department? department,
    Position? position,
    DateTime? hireDate,
    String? managerId,
    Employee? manager,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bankInfo: bankInfo ?? this.bankInfo,
      department: department ?? this.department,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      managerId: managerId ?? this.managerId,
      manager: manager ?? this.manager,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];
}

class Address extends Equatable {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'] as String?,
      line2: json['line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code']?.toString(),
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }

  @override
  List<Object?> get props => [];
}

class EmergencyContact extends Equatable {
  final String? fullName;
  final String? phone;
  final String? relationship;

  const EmergencyContact({this.fullName, this.phone, this.relationship});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      relationship: json['relationship'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'relationship': relationship,
    };
  }

  @override
  List<Object?> get props => [];
}

class BankInfo extends Equatable {
  final String? accountNumber;
  final String? bankName;
  final String? routingNumber;

  const BankInfo({this.accountNumber, this.bankName, this.routingNumber});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      accountNumber: json['account_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      routingNumber: json['routing_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'bank_name': bankName,
      'routing_number': routingNumber,
    };
  }

  @override
  List<Object?> get props => [];
}

class Department extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Department({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id];
}

class Position extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? departmentId;
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
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      departmentId: json['department_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
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
}
