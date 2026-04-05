import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/employee.dart';

class EmployeeService {
  final Dio dio;

  EmployeeService({required this.dio});

  Future<Employee> getEmployeeById(int id) async {
    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/employees/$id',
    );
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Employee>> getEmployees({
    int? managerId,
    int? departmentId,
    String? status,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (managerId != null) queryParameters['manager_id'] = managerId;
    if (departmentId != null) queryParameters['department_id'] = departmentId;
    if (status != null) queryParameters['status'] = status;
    if (search != null) queryParameters['search'] = search;

    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/employees',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Employee.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['employees'];
      if (items is List) {
        return items
            .map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}
