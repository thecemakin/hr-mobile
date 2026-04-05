import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/asset_service.dart';
import '../../data/repositories/asset_repository.dart';
import '../../domain/models/asset.dart';
import 'auth_provider.dart';

final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService(dio: ref.watch(dioClientProvider).dio);
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository(assetService: ref.watch(assetServiceProvider));
});

final myActiveAssetsProvider =
    FutureProvider.family<List<AssetAssignment>, int>((ref, employeeId) async {
      final repository = ref.watch(assetRepositoryProvider);
      return repository.getMyAssignments(
        employeeId: employeeId,
        status: 'assigned',
      );
    });

final myAllAssetsProvider = FutureProvider.family<List<AssetAssignment>, int>((
  ref,
  employeeId,
) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getMyAssignments(employeeId: employeeId);
});

final assetDetailProvider = FutureProvider.family<Asset, int>((
  ref,
  assetId,
) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetById(assetId);
});
