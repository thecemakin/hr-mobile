import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/position_service.dart';
import '../../data/repositories/position_repository.dart';
import '../../domain/models/position.dart';
import 'auth_provider.dart';

final positionServiceProvider = Provider<PositionService>((ref) {
  return PositionService(dio: ref.watch(dioClientProvider).dio);
});

final positionRepositoryProvider = Provider<PositionRepository>((ref) {
  return PositionRepository(
    positionService: ref.watch(positionServiceProvider),
  );
});

final positionsProvider = FutureProvider<List<Position>>((ref) async {
  final repository = ref.watch(positionRepositoryProvider);
  return repository.getPositions();
});

final positionDetailProvider = FutureProvider.family<Position, int>((
  ref,
  id,
) async {
  final repository = ref.watch(positionRepositoryProvider);
  return repository.getPositionById(id);
});
