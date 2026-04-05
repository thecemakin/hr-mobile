import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/usecases/auth_provider.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/leave/leave_screen.dart';
import '../../presentation/employees/employees_screen.dart';
import '../../presentation/organization/organization_screen.dart';
import '../../presentation/assets/assets_screen.dart';
import '../../presentation/departments/departments_screen.dart';
import '../../presentation/positions/positions_screen.dart';
import '../../presentation/employee_directory/employee_directory_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authState.isAuthenticated ? '/dashboard' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      if (!isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }
      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: '/employee-directory',
            builder: (context, state) => const EmployeeDirectoryScreen(),
          ),
          GoRoute(
            path: '/leave',
            builder: (context, state) => const LeaveScreen(),
          ),
          GoRoute(
            path: '/organization',
            builder: (context, state) => const OrganizationScreen(),
          ),
          GoRoute(
            path: '/assets',
            builder: (context, state) => const AssetsScreen(),
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => const DepartmentsScreen(),
          ),
          GoRoute(
            path: '/positions',
            builder: (context, state) => const PositionsScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).roles;
    final currentIndex = _calculateSelectedIndex(context, roles);
    final destinations = _getDestinations(roles);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index, roles),
        destinations: destinations,
      ),
    );
  }

  List<NavigationDestination> _getDestinations(List<String> roles) {
    final isHR = roles.any((r) => r.toLowerCase() == 'hr');
    final isAdmin = roles.any((r) => r.toLowerCase() == 'admin');
    final isHrOrAdmin = isHR || isAdmin;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      if (isHrOrAdmin)
        const NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Çalışanlar',
        )
      else
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      const NavigationDestination(
        icon: Icon(Icons.beach_access_outlined),
        selectedIcon: Icon(Icons.beach_access),
        label: 'İzinler',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_tree_outlined),
        selectedIcon: Icon(Icons.account_tree),
        label: 'Organizasyon',
      ),
      if (isHrOrAdmin)
        const NavigationDestination(
          icon: Icon(Icons.business_outlined),
          selectedIcon: Icon(Icons.business),
          label: 'Yönetim',
        )
      else
        const NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Zimmetler',
        ),
    ];

    return destinations;
  }

  int _calculateSelectedIndex(BuildContext context, List<String> roles) {
    final location = GoRouterState.of(context).matchedLocation;
    final isHR = roles.any((r) => r.toLowerCase() == 'hr');
    final isAdmin = roles.any((r) => r.toLowerCase() == 'admin');
    final isHrOrAdmin = isHR || isAdmin;

    int idx = 0;
    if (location.startsWith('/dashboard')) return 0;
    idx++;

    if (location.startsWith('/employees') ||
        location.startsWith('/employee-directory')) {
      return isHrOrAdmin ? idx : idx;
    }
    if (location.startsWith('/employees')) return idx;
    idx++;

    if (location.startsWith('/leave')) return idx;
    idx++;

    if (location.startsWith('/organization')) return idx;
    idx++;

    if (location.startsWith('/departments') ||
        location.startsWith('/positions')) {
      return idx;
    }
    if (location.startsWith('/assets')) return idx;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index, List<String> roles) {
    final isHR = roles.any((r) => r.toLowerCase() == 'hr');
    final isAdmin = roles.any((r) => r.toLowerCase() == 'admin');
    final isHrOrAdmin = isHR || isAdmin;

    int idx = 0;
    void route(String path) => context.go(path);

    if (index == idx) {
      route('/dashboard');
      return;
    }
    idx++;

    if (index == idx) {
      route(isHrOrAdmin ? '/employee-directory' : '/employees');
      return;
    }
    idx++;

    if (index == idx) {
      route('/leave');
      return;
    }
    idx++;

    if (index == idx) {
      route('/organization');
      return;
    }
    idx++;

    if (index == idx) {
      route(isHrOrAdmin ? '/departments' : '/assets');
      return;
    }
  }
}
