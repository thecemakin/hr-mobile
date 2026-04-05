import 'package:equatable/equatable.dart';
import 'employee.dart';

class Asset extends Equatable {
  final int id;
  final String name;
  final String? type;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? assetTag;
  final String? status;
  final String? condition;
  final String? description;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? warrantyExpires;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Asset({
    required this.id,
    required this.name,
    this.type,
    this.brand,
    this.model,
    this.serialNumber,
    this.assetTag,
    this.status,
    this.condition,
    this.description,
    this.purchaseDate,
    this.purchasePrice,
    this.warrantyExpires,
    this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      assetTag: json['asset_tag'] as String?,
      status: json['status'] as String?,
      condition: json['condition'] as String?,
      description: json['description'] as String?,
      purchaseDate: _parseDate(json['purchase_date']),
      purchasePrice: _toDouble(json['purchase_price']),
      warrantyExpires: _parseDate(json['warranty_expires']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'asset_tag': assetTag,
      'status': status,
      'condition': condition,
      'description': description,
      'purchase_date': purchaseDate?.toIso8601String(),
      'purchase_price': purchasePrice,
      'warranty_expires': warrantyExpires?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isUnderWarranty {
    if (warrantyExpires == null) return false;
    return warrantyExpires!.isAfter(DateTime.now());
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

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty || s == '0001-01-01T00:00:00Z') return null;
    return DateTime.tryParse(s);
  }
}

class AssetAssignment extends Equatable {
  final int id;
  final int assetId;
  final int employeeId;
  final DateTime? assignedDate;
  final DateTime? returnedDate;
  final String? status;
  final String? notes;
  final int? assignedBy;
  final int? returnedBy;
  final Asset? asset;
  final Employee? employee;
  final Employee? assigner;
  final Employee? returner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssetAssignment({
    required this.id,
    required this.assetId,
    required this.employeeId,
    this.assignedDate,
    this.returnedDate,
    this.status,
    this.notes,
    this.assignedBy,
    this.returnedBy,
    this.asset,
    this.employee,
    this.assigner,
    this.returner,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetAssignment.fromJson(Map<String, dynamic> json) {
    return AssetAssignment(
      id: _toInt(json['id']) ?? 0,
      assetId: _toInt(json['asset_id']) ?? 0,
      employeeId: _toInt(json['employee_id']) ?? 0,
      assignedDate: _parseDate(json['assigned_date']),
      returnedDate: _parseDate(json['returned_date']),
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      assignedBy: _toInt(json['assigned_by']),
      returnedBy: _toInt(json['returned_by']),
      asset: json['asset'] != null
          ? Asset.fromJson(json['asset'] as Map<String, dynamic>)
          : null,
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      assigner: json['assigner'] != null
          ? Employee.fromJson(json['assigner'] as Map<String, dynamic>)
          : null,
      returner: json['returner'] != null
          ? Employee.fromJson(json['returner'] as Map<String, dynamic>)
          : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'employee_id': employeeId,
      'assigned_date': assignedDate?.toIso8601String(),
      'returned_date': returnedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'assigned_by': assignedBy,
      'returned_by': returnedBy,
      'asset': asset?.toJson(),
      'employee': employee?.toJson(),
      'assigner': assigner?.toJson(),
      'returner': returner?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'assigned';

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
