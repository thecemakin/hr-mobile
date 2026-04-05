import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/department.dart';

class DepartmentService {
  final Dio dio;

  DepartmentService({required this.dio});

  Future<List<Department>> getDepartments({
    String? name,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit, 'offset': offset};
    if (name != null) queryParameters['name'] = name;

    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/departments',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['departments'];
      if (items is List) {
        return items
            .map((e) => Department.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<Department> getDepartmentById(int id) async {
    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/departments/$id',
    );
    return Department.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Department> createDepartment(Department department) async {
    final response = await dio.post(
      '${AppConstants.apiV1}/corehr/departments',
      data: department.toJson(),
    );
    return Department.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Department> updateDepartment(int id, Department department) async {
    final response = await dio.put(
      '${AppConstants.apiV1}/corehr/departments/$id',
      data: department.toJson(),
    );
    return Department.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteDepartment(int id) async {
    await dio.delete('${AppConstants.apiV1}/corehr/departments/$id');
  }
}
