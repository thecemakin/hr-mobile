import '../../domain/models/position.dart';
import '../api/position_service.dart';

class PositionRepository {
  final PositionService _positionService;

  PositionRepository({required PositionService positionService})
    : _positionService = positionService;

  Future<List<Position>> getPositions({
    String? title,
    int limit = 50,
    int offset = 0,
  }) {
    return _positionService.getPositions(
      title: title,
      limit: limit,
      offset: offset,
    );
  }

  Future<Position> getPositionById(int id) {
    return _positionService.getPositionById(id);
  }

  Future<Position> createPosition(Position position) {
    return _positionService.createPosition(position);
  }

  Future<Position> updatePosition(int id, Position position) {
    return _positionService.updatePosition(id, position);
  }

  Future<void> deletePosition(int id) {
    return _positionService.deletePosition(id);
  }
}
