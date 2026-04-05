import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/asset.dart';

class AssetService {
  final Dio dio;

  AssetService({required this.dio});

  Future<List<AssetAssignment>> getMyAssignments({
    required String employeeId,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{'employee_id': employeeId};
    if (status != null) queryParameters['status'] = status;

    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/asset-assignments',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => AssetAssignment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['assignments'];
      if (items is List) {
        return items
            .map((e) => AssetAssignment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<Asset> getAssetById(String id) async {
    final response = await dio.get('${AppConstants.apiV1}/corehr/assets/$id');
    return Asset.fromJson(response.data as Map<String, dynamic>);
  }
}
