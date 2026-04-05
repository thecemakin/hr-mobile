import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/employee.dart';
import '../../domain/usecases/employee_provider.dart';
import '../../domain/usecases/department_provider.dart';

class EmployeeDirectoryScreen extends ConsumerStatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  ConsumerState<EmployeeDirectoryScreen> createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState
    extends ConsumerState<EmployeeDirectoryScreen> {
  final _searchController = TextEditingController();
  int? _selectedDepartmentId;
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Çalışanlar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'İsme göre ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDepartmentFilter()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusFilter()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: employeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Hata: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(employeesListProvider),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
              data: (employees) {
                if (employees.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Çalışan bulunamadı',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return _EmployeeCard(employee: emp);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    final departmentsAsync = ref.watch(departmentsProvider);

    return departmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox(),
      data: (departments) {
        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Departman',
            border: OutlineInputBorder(),
          ),
          initialValue: _selectedDepartmentId,
          hint: const Text('Tümü'),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('Tümü')),
            ...departments.map(
              (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
            ),
          ],
          onChanged: (v) {
            setState(() => _selectedDepartmentId = v);
            _applyFilters();
          },
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Durum',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedStatus,
      hint: const Text('Tümü'),
      items: const [
        DropdownMenuItem<String>(value: null, child: Text('Tümü')),
        DropdownMenuItem<String>(value: 'active', child: Text('Aktif')),
        DropdownMenuItem<String>(value: 'inactive', child: Text('Pasif')),
        DropdownMenuItem<String>(
          value: 'terminated',
          child: Text('İşten Çıkarıldı'),
        ),
      ],
      onChanged: (v) {
        setState(() => _selectedStatus = v);
        _applyFilters();
      },
    );
  }

  void _applyFilters() {
    ref.invalidate(employeesListProvider);
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(employee.status).withValues(alpha: 0.1),
          child: Text(
            '${employee.firstName[0]}${employee.lastName[0]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _statusColor(employee.status),
            ),
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.position != null) Text(employee.position!.title),
            if (employee.department != null)
              Text(
                employee.department!.name,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            if (employee.email != null)
              Text(
                employee.email!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(employee.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _statusLabel(employee.status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor(employee.status),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green.shade700;
      case 'inactive':
        return Colors.grey.shade600;
      case 'terminated':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade500;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Pasif';
      case 'terminated':
        return 'Ayrıldı';
      default:
        return status ?? '-';
    }
  }
}
