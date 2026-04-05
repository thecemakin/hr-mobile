import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/leave_service.dart';
import '../../data/repositories/leave_repository.dart';
import '../../domain/models/leave.dart';
import 'auth_provider.dart';

final leaveServiceProvider = Provider<LeaveService>((ref) {
  return LeaveService(dio: ref.watch(dioClientProvider).dio);
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(leaveService: ref.watch(leaveServiceProvider));
});

final leaveBalancesProvider = FutureProvider.family<List<LeaveBalance>, int>((
  ref,
  employeeId,
) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaveBalances(employeeId);
});

final leaveTypesProvider = FutureProvider<List<LeaveType>>((ref) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaveTypes();
});

final myLeaveRequestsProvider = FutureProvider.family<List<LeaveRequest>, int>((
  ref,
  employeeId,
) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getMyRequests(employeeId: employeeId);
});

final pendingApprovalsProvider = FutureProvider.family<List<LeaveRequest>, int>(
  (ref, managerId) async {
    final repository = ref.watch(leaveRepositoryProvider);
    return repository.getPendingApprovals(managerId);
  },
);
