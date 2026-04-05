import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/employee_service.dart';
import '../../data/repositories/employee_repository.dart';
import '../../domain/models/employee.dart';
import 'auth_provider.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService(dio: ref.watch(dioClientProvider).dio);
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(
    employeeService: ref.watch(employeeServiceProvider),
  );
});

final employeeProvider = FutureProvider.family<Employee, String>((
  ref,
  id,
) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeById(id);
});

final employeeDirectReportsProvider =
    FutureProvider.family<List<Employee>, String>((ref, managerId) async {
      final repository = ref.watch(employeeRepositoryProvider);
      return repository.getDirectReports(managerId);
    });

final employeesListProvider = FutureProvider<List<Employee>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployees();
});
