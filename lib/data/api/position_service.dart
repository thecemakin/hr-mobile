import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/position.dart';

class PositionService {
  final Dio dio;

  PositionService({required this.dio});

  Future<List<Position>> getPositions({
    String? title,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit, 'offset': offset};
    if (title != null) queryParameters['title'] = title;

    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/positions',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['positions'];
      if (items is List) {
        return items
            .map((e) => Position.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<Position> getPositionById(int id) async {
    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/positions/$id',
    );
    return Position.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Position> createPosition(Position position) async {
    final response = await dio.post(
      '${AppConstants.apiV1}/corehr/positions',
      data: position.toJson(),
    );
    return Position.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Position> updatePosition(int id, Position position) async {
    final response = await dio.put(
      '${AppConstants.apiV1}/corehr/positions/$id',
      data: position.toJson(),
    );
    return Position.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePosition(int id) async {
    await dio.delete('${AppConstants.apiV1}/corehr/positions/$id');
  }
}
