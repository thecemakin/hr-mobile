import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/department_service.dart';
import '../../data/repositories/department_repository.dart';
import '../../domain/models/department.dart';
import 'auth_provider.dart';

final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService(dio: ref.watch(dioClientProvider).dio);
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepository(
    departmentService: ref.watch(departmentServiceProvider),
  );
});

final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  final repository = ref.watch(departmentRepositoryProvider);
  return repository.getDepartments();
});

final departmentDetailProvider = FutureProvider.family<Department, int>((
  ref,
  id,
) async {
  final repository = ref.watch(departmentRepositoryProvider);
  return repository.getDepartmentById(id);
});
