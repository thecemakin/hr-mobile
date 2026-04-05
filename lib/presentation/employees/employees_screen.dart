import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/employee.dart';
import '../../domain/usecases/auth_provider.dart';
import '../../domain/usecases/employee_provider.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userIdStr = authState.userId;

    if (userIdStr == null || userIdStr.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Kullanıcı bilgisi bulunamadı'),
            ],
          ),
        ),
      );
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Geçersiz kullanıcı ID')));
    }

    final employeeAsync = ref.watch(employeeProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: employeeAsync.when(
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
                onPressed: () => ref.invalidate(employeeProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (employee) => _ProfileContent(employee: employee),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Employee employee;
  const _ProfileContent({required this.employee});

  bool get hasAddress =>
      employee.addressLine1 != null ||
      employee.addressLine2 != null ||
      employee.city != null ||
      employee.state != null ||
      employee.postalCode != null ||
      employee.country != null;

  bool get hasEmergencyContact =>
      employee.emergencyContactName != null ||
      employee.emergencyContactPhone != null ||
      employee.emergencyContactRelation != null;

  bool get hasBankInfo =>
      employee.bankName != null ||
      employee.bankAccountNumber != null ||
      employee.bankRoutingNumber != null;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'İş Bilgileri',
              icon: Icons.badge_outlined,
              children: [
                _buildInfoRow('Çalışan No', employee.employeeNumber ?? '-'),
                _buildInfoRow('Departman', employee.department?.name ?? '-'),
                _buildInfoRow('Pozisyon', employee.position?.title ?? '-'),
                _buildInfoRow(
                  'İşe Alım Tarihi',
                  employee.hireDate != null
                      ? DateFormat(
                          'dd MMMM yyyy',
                          'tr_TR',
                        ).format(employee.hireDate!)
                      : '-',
                ),
                _buildInfoRow('Durum', _statusLabel(employee.status)),
              ],
            ),
            if (hasAddress) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'Adres Bilgileri',
                icon: Icons.location_on_outlined,
                children: [
                  if (employee.addressLine1 != null)
                    _buildInfoRow('Adres', employee.addressLine1!),
                  if (employee.addressLine2 != null)
                    _buildInfoRow('Adres (Devam)', employee.addressLine2!),
                  _buildInfoRow('Şehir', employee.city ?? '-'),
                  _buildInfoRow('Eyalet', employee.state ?? '-'),
                  _buildInfoRow('Posta Kodu', employee.postalCode ?? '-'),
                  _buildInfoRow('Ülke', employee.country ?? '-'),
                ],
              ),
            ],
            if (hasEmergencyContact) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'Acil Durum Kişisi',
                icon: Icons.emergency_outlined,
                children: [
                  _buildInfoRow(
                    'Ad Soyad',
                    employee.emergencyContactName ?? '-',
                  ),
                  _buildInfoRow(
                    'Telefon',
                    employee.emergencyContactPhone ?? '-',
                  ),
                  _buildInfoRow(
                    'İlişki',
                    employee.emergencyContactRelation ?? '-',
                  ),
                ],
              ),
            ],
            if (hasBankInfo) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'Banka Bilgileri',
                icon: Icons.account_balance_outlined,
                children: [
                  _buildInfoRow('Banka', employee.bankName ?? '-'),
                  _buildInfoRow('Hesap No', employee.bankAccountNumber ?? '-'),
                  _buildInfoRow(
                    'Routing No',
                    employee.bankRoutingNumber ?? '-',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                '${employee.firstName[0]}${employee.lastName[0]}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.email ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (employee.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      employee.phone!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Pasif';
      case 'terminated':
        return 'İşten Çıkarıldı';
      case 'on_leave':
        return 'İzinde';
      default:
        return status ?? '-';
    }
  }
}
