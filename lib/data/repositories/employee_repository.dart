import '../../domain/models/employee.dart';
import '../api/employee_service.dart';

class EmployeeRepository {
  final EmployeeService _employeeService;

  EmployeeRepository({required EmployeeService employeeService})
    : _employeeService = employeeService;

  Future<Employee> getEmployeeById(String id) {
    return _employeeService.getEmployeeById(id);
  }

  Future<List<Employee>> getEmployees({
    String? managerId,
    String? departmentId,
    String? status,
    String? search,
  }) {
    return _employeeService.getEmployees(
      managerId: managerId,
      departmentId: departmentId,
      status: status,
      search: search,
    );
  }

  Future<List<Employee>> getDirectReports(String managerId) {
    return _employeeService.getEmployees(managerId: managerId);
  }
}
