import '../../domain/models/employee.dart';
import '../api/employee_service.dart';

class EmployeeRepository {
  final EmployeeService _employeeService;

  EmployeeRepository({required EmployeeService employeeService})
    : _employeeService = employeeService;

  Future<Employee> getEmployeeById(int id) {
    return _employeeService.getEmployeeById(id);
  }

  Future<List<Employee>> getEmployees({
    int? managerId,
    int? departmentId,
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

  Future<List<Employee>> getDirectReports(int managerId) {
    return _employeeService.getEmployees(managerId: managerId);
  }
}
