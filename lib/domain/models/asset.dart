import 'package:equatable/equatable.dart';

class Asset extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? status;
  final DateTime? purchaseDate;
  final DateTime? warrantyEndDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Asset({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.model,
    this.serialNumber,
    this.status,
    this.purchaseDate,
    this.warrantyEndDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      status: json['status'] as String?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      warrantyEndDate: json['warranty_end_date'] != null
          ? DateTime.parse(json['warranty_end_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'status': status,
      'purchase_date': purchaseDate?.toIso8601String(),
      'warranty_end_date': warrantyEndDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isUnderWarranty {
    if (warrantyEndDate == null) return false;
    return warrantyEndDate!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [id];
}

class AssetAssignment extends Equatable {
  final String id;
  final String assetId;
  final String employeeId;
  final DateTime? assignedDate;
  final DateTime? returnDate;
  final String? status;
  final String? notes;
  final Asset? asset;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssetAssignment({
    required this.id,
    required this.assetId,
    required this.employeeId,
    this.assignedDate,
    this.returnDate,
    this.status,
    this.notes,
    this.asset,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetAssignment.fromJson(Map<String, dynamic> json) {
    return AssetAssignment(
      id: json['id'] as String,
      assetId: json['asset_id'] as String,
      employeeId: json['employee_id'] as String,
      assignedDate: json['assigned_date'] != null
          ? DateTime.parse(json['assigned_date'] as String)
          : null,
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      asset: json['asset'] != null
          ? Asset.fromJson(json['asset'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'employee_id': employeeId,
      'assigned_date': assignedDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'asset': asset?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'assigned';

  @override
  List<Object?> get props => [id];
}
