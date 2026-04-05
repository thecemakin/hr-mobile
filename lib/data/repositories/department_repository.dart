import '../../domain/models/department.dart';
import '../api/department_service.dart';

class DepartmentRepository {
  final DepartmentService _departmentService;

  DepartmentRepository({required DepartmentService departmentService})
    : _departmentService = departmentService;

  Future<List<Department>> getDepartments({
    String? name,
    int limit = 50,
    int offset = 0,
  }) {
    return _departmentService.getDepartments(
      name: name,
      limit: limit,
      offset: offset,
    );
  }

  Future<Department> getDepartmentById(int id) {
    return _departmentService.getDepartmentById(id);
  }

  Future<Department> createDepartment(Department department) {
    return _departmentService.createDepartment(department);
  }

  Future<Department> updateDepartment(int id, Department department) {
    return _departmentService.updateDepartment(id, department);
  }

  Future<void> deleteDepartment(int id) {
    return _departmentService.deleteDepartment(id);
  }
}
