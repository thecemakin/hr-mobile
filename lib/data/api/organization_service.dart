import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/organization.dart';

class OrganizationService {
  final Dio dio;

  OrganizationService({required this.dio});

  Future<OrganizationNode> getOrganizationTree() async {
    final response = await dio.get(
      '${AppConstants.apiV1}/corehr/organization/tree',
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return OrganizationNode.fromJson(data);
    }

    if (data is List) {
      if (data.isEmpty) {
        throw Exception('Organizasyon verisi boş');
      }

      final List<OrganizationNode> allNodes = data
          .map((e) => OrganizationNode.fromJson(e as Map<String, dynamic>))
          .toList();

      final List<OrganizationNode> rootNodes = allNodes
          .where((node) => node.parentId == null)
          .toList();

      if (rootNodes.isEmpty) {
        rootNodes.add(allNodes.first);
      }

      if (rootNodes.length == 1) {
        return rootNodes.first;
      }

      return OrganizationNode(
        id: 0,
        name: 'Organizasyon',
        type: 'root',
        children: rootNodes,
      );
    }

    throw Exception('Beklenmeyen veri formatı: ${data.runtimeType}');
  }
}
