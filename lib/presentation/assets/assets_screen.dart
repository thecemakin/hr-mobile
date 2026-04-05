import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/asset.dart';
import '../../domain/usecases/auth_provider.dart';
import '../../domain/usecases/asset_provider.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Zimmetler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif', icon: Icon(Icons.laptop, size: 18)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ActiveAssetsTab(), _AssetHistoryTab()],
      ),
    );
  }
}

class _ActiveAssetsTab extends ConsumerWidget {
  const _ActiveAssetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdStr = ref.watch(authProvider).userId;

    if (userIdStr == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      return const Center(child: Text('Geçersiz kullanıcı ID'));
    }

    final assetsAsync = ref.watch(myActiveAssetsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myActiveAssetsProvider(userId)),
      child: assetsAsync.when(
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
                onPressed: () => ref.invalidate(myActiveAssetsProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.laptop_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aktif zimmetiniz bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return _AssetCard(assignment: assignment);
            },
          );
        },
      ),
    );
  }
}

class _AssetHistoryTab extends ConsumerWidget {
  const _AssetHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdStr = ref.watch(authProvider).userId;

    if (userIdStr == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      return const Center(child: Text('Geçersiz kullanıcı ID'));
    }

    final historyAsync = ref.watch(myAllAssetsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myAllAssetsProvider(userId)),
      child: historyAsync.when(
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
                onPressed: () => ref.invalidate(myAllAssetsProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Zimmet geçmişiniz bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return _AssetCard(assignment: assignment, showReturnDate: true);
            },
          );
        },
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final AssetAssignment assignment;
  final bool showReturnDate;

  const _AssetCard({required this.assignment, this.showReturnDate = false});

  @override
  Widget build(BuildContext context) {
    final asset = assignment.asset;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _assetIcon(asset?.type),
                    size: 28,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset?.name ?? 'Zimmet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (asset?.brand != null || asset?.model != null)
                        Text(
                          [
                            asset?.brand,
                            asset?.model,
                          ].where((e) => e != null).join(' '),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: assignment.status),
              ],
            ),
            const Divider(height: 24),
            if (asset?.serialNumber != null)
              _InfoRow(label: 'Seri No', value: asset!.serialNumber!),
            _InfoRow(
              label: 'Atama Tarihi',
              value: assignment.assignedDate != null
                  ? DateFormat(
                      'dd MMM yyyy',
                      'tr_TR',
                    ).format(assignment.assignedDate!)
                  : '-',
            ),
            if (showReturnDate)
              _InfoRow(
                label: 'İade Tarihi',
                value: assignment.returnedDate != null
                    ? DateFormat(
                        'dd MMM yyyy',
                        'tr_TR',
                      ).format(assignment.returnedDate!)
                    : '-',
              ),
            if (asset?.warrantyExpires != null)
              _InfoRow(
                label: 'Garanti Bitiş',
                value: DateFormat(
                  'dd MMM yyyy',
                  'tr_TR',
                ).format(asset!.warrantyExpires!),
                trailing: asset.isUnderWarranty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Garantili',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade800,
                          ),
                        ),
                      )
                    : null,
              ),
            if (assignment.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  assignment.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _assetIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'laptop':
      case 'computer':
        return Icons.laptop;
      case 'phone':
      case 'mobile':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet;
      case 'monitor':
        return Icons.monitor;
      case 'keyboard':
        return Icons.keyboard;
      case 'mouse':
        return Icons.mouse;
      case 'desk':
      case 'furniture':
        return Icons.chair;
      default:
        return Icons.devices;
    }
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
      case 'assigned':
        return 'Zimmetli';
      case 'returned':
        return 'İade Edildi';
      case 'pending':
        return 'Beklemede';
      default:
        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'assigned':
        return Colors.blue.shade700;
      case 'returned':
        return Colors.grey.shade600;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade500;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
