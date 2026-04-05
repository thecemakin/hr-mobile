import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/leave.dart';

class LeaveService {
  final Dio dio;

  LeaveService({required this.dio});

  Future<List<LeaveBalance>> getLeaveBalances(int employeeId) async {
    final response = await dio.get(
      '${AppConstants.apiV1}/leave/leave-balances/$employeeId',
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['balances'];
      if (items is List) {
        return items
            .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await dio.get('${AppConstants.apiV1}/leave/leave-types');

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['types'];
      if (items is List) {
        return items
            .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<List<LeaveRequest>> getMyRequests({
    required int employeeId,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{'employeeId': employeeId};
    if (status != null) queryParameters['status'] = status;

    final response = await dio.get(
      '${AppConstants.apiV1}/leave/leave-requests/me',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['requests'];
      if (items is List) {
        return items
            .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<LeaveRequest> createLeaveRequest({
    required int employeeId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final response = await dio.post(
      '${AppConstants.apiV1}/leave/leave-requests',
      data: {
        'employee_id': employeeId,
        'leave_type_id': leaveTypeId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'reason': reason,
      },
    );

    return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<LeaveRequest>> getPendingApprovals(int managerId) async {
    final response = await dio.get(
      '${AppConstants.apiV1}/leave/leave-requests/pending-approvals',
      queryParameters: {'managerId': managerId},
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items =
          data['data'] ?? data['results'] ?? data['pending_approvals'];
      if (items is List) {
        return items
            .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<void> approveLeaveRequest({
    required int requestId,
    required int managerId,
    String? note,
  }) async {
    await dio.post(
      '${AppConstants.apiV1}/leave/leave-requests/$requestId/approve',
      queryParameters: {'managerId': managerId},
      data: note != null ? {'note': note} : <String, dynamic>{},
    );
  }

  Future<void> rejectLeaveRequest({
    required int requestId,
    required int managerId,
    required String note,
  }) async {
    await dio.post(
      '${AppConstants.apiV1}/leave/leave-requests/$requestId/reject',
      queryParameters: {'managerId': managerId},
      data: {'note': note},
    );
  }
}
