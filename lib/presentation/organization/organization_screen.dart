import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/organization.dart';
import '../../domain/usecases/auth_provider.dart';
import '../../domain/usecases/employee_provider.dart';
import '../../domain/usecases/organization_provider.dart';

class OrganizationScreen extends ConsumerStatefulWidget {
  const OrganizationScreen({super.key});

  @override
  ConsumerState<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends ConsumerState<OrganizationScreen>
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
        title: const Text('Organizasyon'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ağaç', icon: Icon(Icons.account_tree, size: 18)),
            Tab(text: 'Ekibim', icon: Icon(Icons.people, size: 18)),
            Tab(text: 'Yöneticim', icon: Icon(Icons.person, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OrgTreeTab(), _MyTeamTab(), _MyManagerTab()],
      ),
    );
  }
}

class _OrgTreeTab extends ConsumerWidget {
  const _OrgTreeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(organizationTreeProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(organizationTreeProvider),
      child: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Organizasyon ağacı yüklenirken hata oluştu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      error.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(organizationTreeProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (tree) => _OrganizationTreeView(root: tree),
      ),
    );
  }
}

class _OrganizationTreeView extends StatefulWidget {
  final OrganizationNode root;
  const _OrganizationTreeView({required this.root});

  @override
  State<_OrganizationTreeView> createState() => _OrganizationTreeViewState();
}

class _OrganizationTreeViewState extends State<_OrganizationTreeView> {
  final Set<String> _expandedNodes = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debug info: Show node count
          Text(
            'Toplam ${_countNodes(widget.root)} düğüm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Build all root nodes (if there are multiple)
          ..._buildRootNodes(),
        ],
      ),
    );
  }

  int _countNodes(OrganizationNode node) {
    return 1 + node.children.map(_countNodes).fold(0, (a, b) => a + b);
  }

  List<Widget> _buildRootNodes() {
    // If the root is a virtual root with type 'root', show all its children
    if (widget.root.type == 'root') {
      return widget.root.children.map((child) => _buildNode(child, 0)).toList();
    }
    // Otherwise, just show the single root node
    return [_buildNode(widget.root, 0)];
  }

  Widget _buildNode(OrganizationNode node, int depth) {
    final isExpanded = _expandedNodes.contains(node.id);
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren
              ? () => setState(() {
                  if (isExpanded) {
                    _expandedNodes.remove(node.id);
                  } else {
                    _expandedNodes.add(node.id);
                  }
                })
              : null,
          child: Container(
            margin: EdgeInsets.only(left: depth * 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: node.isDepartment
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: node.isDepartment
                    ? Colors.blue.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Icon(
                  node.isDepartment
                      ? Icons.business
                      : node.isPosition
                      ? Icons.badge
                      : Icons.person,
                  size: 18,
                  color: node.isDepartment
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (node.position != null)
                        Text(
                          node.position!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      if (node.directReportsCount != null &&
                          node.directReportsCount! > 0)
                        Text(
                          '${node.directReportsCount} kişi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          ...node.children.map((child) => _buildNode(child, depth + 1)),
      ],
    );
  }
}

class _MyTeamTab extends ConsumerWidget {
  const _MyTeamTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (userId == null || userId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Kullanıcı bilgisi bulunamadı'),
          ],
        ),
      );
    }

    final teamAsync = ref.watch(employeeDirectReportsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(employeeDirectReportsProvider(userId)),
      child: teamAsync.when(
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
                    ref.invalidate(employeeDirectReportsProvider(userId)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (team) {
          if (team.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Yönettiğiniz ekip bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: team.length,
            itemBuilder: (context, index) {
              final member = team[index];
              return _TeamMemberCard(employee: member);
            },
          );
        },
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Employee employee;
  const _TeamMemberCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            '${employee.firstName[0]}${employee.lastName[0]}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text('${employee.firstName} ${employee.lastName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.position != null) Text(employee.position!.title),
            if (employee.department != null)
              Text(
                employee.department!.name,
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (employee.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: employee.status == 'active'
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(employee.status),
                  style: TextStyle(
                    fontSize: 11,
                    color: employee.status == 'active'
                        ? Colors.green.shade800
                        : Colors.grey.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Pasif';
      case 'on_leave':
        return 'İzinde';
      default:
        return status ?? '-';
    }
  }
}

class _MyManagerTab extends ConsumerWidget {
  const _MyManagerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (userId == null || userId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Kullanıcı bilgisi bulunamadı'),
          ],
        ),
      );
    }

    final employeeAsync = ref.watch(employeeProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(employeeProvider(userId)),
      child: employeeAsync.when(
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
        data: (employee) {
          final manager = employee.manager;

          if (manager == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Yönetici bilgisi bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yöneticim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            '${manager.firstName[0]}${manager.lastName[0]}',
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
                                '${manager.firstName} ${manager.lastName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (manager.position != null)
                                Text(
                                  manager.position!.title,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              if (manager.department != null)
                                Text(
                                  manager.department!.name,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              if (manager.email != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      manager.email!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                              if (manager.phone != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      manager.phone!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
