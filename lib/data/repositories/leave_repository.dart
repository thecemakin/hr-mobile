import '../../domain/models/leave.dart';
import '../api/leave_service.dart';

class LeaveRepository {
  final LeaveService _leaveService;

  LeaveRepository({required LeaveService leaveService})
    : _leaveService = leaveService;

  Future<List<LeaveBalance>> getLeaveBalances(int employeeId) {
    return _leaveService.getLeaveBalances(employeeId);
  }

  Future<List<LeaveType>> getLeaveTypes() {
    return _leaveService.getLeaveTypes();
  }

  Future<List<LeaveRequest>> getMyRequests({
    required int employeeId,
    String? status,
  }) {
    return _leaveService.getMyRequests(employeeId: employeeId, status: status);
  }

  Future<LeaveRequest> createLeaveRequest({
    required int employeeId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) {
    return _leaveService.createLeaveRequest(
      employeeId: employeeId,
      leaveTypeId: leaveTypeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  Future<List<LeaveRequest>> getPendingApprovals(int managerId) {
    return _leaveService.getPendingApprovals(managerId);
  }

  Future<void> approveLeaveRequest({
    required int requestId,
    required int managerId,
    String? note,
  }) {
    return _leaveService.approveLeaveRequest(
      requestId: requestId,
      managerId: managerId,
      note: note,
    );
  }

  Future<void> rejectLeaveRequest({
    required int requestId,
    required int managerId,
    required String note,
  }) {
    return _leaveService.rejectLeaveRequest(
      requestId: requestId,
      managerId: managerId,
      note: note,
    );
  }
}
