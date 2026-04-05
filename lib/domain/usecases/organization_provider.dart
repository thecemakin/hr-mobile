import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/organization_service.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/models/organization.dart';
import 'auth_provider.dart';

final organizationServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService(dio: ref.watch(dioClientProvider).dio);
});

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(
    organizationService: ref.watch(organizationServiceProvider),
  );
});

final organizationTreeProvider = FutureProvider<OrganizationNode>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizationTree();
});
