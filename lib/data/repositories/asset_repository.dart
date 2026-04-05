import '../../domain/models/asset.dart';
import '../api/asset_service.dart';

class AssetRepository {
  final AssetService _assetService;

  AssetRepository({required AssetService assetService})
    : _assetService = assetService;

  Future<List<AssetAssignment>> getMyAssignments({
    required String employeeId,
    String? status,
  }) {
    return _assetService.getMyAssignments(
      employeeId: employeeId,
      status: status,
    );
  }

  Future<Asset> getAssetById(String id) {
    return _assetService.getAssetById(id);
  }
}
