import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/leave.dart';
import '../../domain/usecases/auth_provider.dart';
import '../../domain/usecases/leave_provider.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İzinler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bakiyeler', icon: Icon(Icons.pie_chart, size: 18)),
            Tab(text: 'Talepler', icon: Icon(Icons.list, size: 18)),
            Tab(text: 'Onaylar', icon: Icon(Icons.approval, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaveBalancesTab(),
          _MyRequestsTab(),
          _PendingApprovalsTab(),
        ],
      ),
    );
  }
}

class _LeaveBalancesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = _getUserId(ref);
    if (userId == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    final balancesAsync = ref.watch(leaveBalancesProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(leaveBalancesProvider(userId)),
      child: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(leaveBalancesProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (balances) {
          if (balances.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'İzin bakiyesi bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: balances.length,
            itemBuilder: (context, index) {
              final balance = balances[index];
              return _BalanceCard(balance: balance);
            },
          );
        },
      ),
    );
  }

  int? _getUserId(WidgetRef ref) {
    final userIdStr = ref.watch(authProvider).userId;
    if (userIdStr == null || userIdStr.isEmpty) return null;
    return int.tryParse(userIdStr);
  }
}

class _BalanceCard extends StatelessWidget {
  final LeaveBalance balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final typeName =
        balance.leaveType?.name ?? 'İzin Tipi #${balance.leaveTypeId}';
    final usagePercent = balance.usagePercent.clamp(0.0, 100.0);
    final remaining = balance.remainingDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    typeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: remaining > 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    remaining > 0 ? '$remaining gün kaldı' : 'Tükendi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: remaining > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: usagePercent / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercent > 80
                      ? Colors.orange
                      : usagePercent >= 100
                      ? Colors.red
                      : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam: ${balance.totalDays} gün',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Kullanılan: ${balance.usedDays} gün',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = _getUserId(ref);
    if (userId == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    final requestsAsync = ref.watch(myLeaveRequestsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myLeaveRequestsProvider(userId)),
      child: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(myLeaveRequestsProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz izin talebiniz bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showNewRequestDialog(context, ref, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Talep'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(request: request);
            },
          );
        },
      ),
    );
  }

  int? _getUserId(WidgetRef ref) {
    final userIdStr = ref.watch(authProvider).userId;
    if (userIdStr == null || userIdStr.isEmpty) return null;
    return int.tryParse(userIdStr);
  }

  void _showNewRequestDialog(BuildContext context, WidgetRef ref, int userId) {
    showDialog(
      context: context,
      builder: (context) => _NewLeaveRequestDialog(userId: userId),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final LeaveRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${dateFormat.format(request.startDate)} - ${dateFormat.format(request.endDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            if (request.totalDaysRequested != null)
              Text(
                '${request.totalDaysRequested} gün',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            if (request.reason != null) ...[
              const SizedBox(height: 4),
              Text(
                request.reason!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
            if (request.isRejected && request.reviewerNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Red nedeni: ${request.reviewerNote}',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade500;
    }
  }
}

class _NewLeaveRequestDialog extends ConsumerStatefulWidget {
  final int userId;
  const _NewLeaveRequestDialog({required this.userId});

  @override
  ConsumerState<_NewLeaveRequestDialog> createState() =>
      _NewLeaveRequestDialogState();
}

class _NewLeaveRequestDialogState
    extends ConsumerState<_NewLeaveRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedLeaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveTypesAsync = ref.watch(leaveTypesProvider);

    return AlertDialog(
      title: const Text('Yeni İzin Talebi'),
      content: SizedBox(
        width: double.maxFinite,
        child: leaveTypesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Hata: $error'),
          data: (leaveTypes) {
            final activeTypes = leaveTypes.where((t) => t.isActive).toList();

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'İzin Tipi',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedLeaveTypeId,
                    items: activeTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLeaveTypeId = value),
                    validator: (value) =>
                        value == null ? 'İzin tipi seçiniz' : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Başlangıç Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'tr_TR',
                              ).format(_startDate!)
                            : 'Tarih seçiniz',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Bitiş Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'tr_TR',
                              ).format(_endDate!)
                            : 'Tarih seçiniz',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (İsteğe bağlı)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen tarih seçiniz')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(leaveRepositoryProvider);
      await repository.createLeaveRequest(
        employeeId: widget.userId,
        leaveTypeId: _selectedLeaveTypeId!,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.isEmpty ? null : _reasonController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(myLeaveRequestsProvider(widget.userId));
        ref.invalidate(leaveBalancesProvider(widget.userId));
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İzin talebi gönderildi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _PendingApprovalsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = _getUserId(ref);
    if (userId == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    final approvalsAsync = ref.watch(pendingApprovalsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingApprovalsProvider(userId)),
      child: approvalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(pendingApprovalsProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.approval_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Bekleyen onay bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _ApprovalCard(request: request, managerId: userId);
            },
          );
        },
      ),
    );
  }

  int? _getUserId(WidgetRef ref) {
    final userIdStr = ref.watch(authProvider).userId;
    if (userIdStr == null || userIdStr.isEmpty) return null;
    return int.tryParse(userIdStr);
  }
}

class _ApprovalCard extends ConsumerStatefulWidget {
  final LeaveRequest request;
  final int managerId;
  const _ApprovalCard({required this.request, required this.managerId});

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dateFormat.format(widget.request.startDate)} - ${dateFormat.format(widget.request.endDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.request.totalDaysRequested != null)
                  Text(
                    '${widget.request.totalDaysRequested} gün',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
              ],
            ),
            if (widget.request.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.request.reason!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _showRejectDialog,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reddet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Onayla'),
                    onPressed: _isProcessing ? null : _approve,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(leaveRepositoryProvider);
      await repository.approveLeaveRequest(
        requestId: widget.request.id,
        managerId: widget.managerId,
      );

      if (mounted) {
        ref.invalidate(pendingApprovalsProvider(widget.managerId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İzin talebi onaylandı')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showRejectDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İzin Talebini Reddet'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Red nedeni (zorunlu)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              _reject(controller.text);
            },
            child: const Text('Reddet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reject(String note) async {
    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(leaveRepositoryProvider);
      await repository.rejectLeaveRequest(
        requestId: widget.request.id,
        managerId: widget.managerId,
        note: note,
      );

      if (mounted) {
        ref.invalidate(pendingApprovalsProvider(widget.managerId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İzin talebi reddedildi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
