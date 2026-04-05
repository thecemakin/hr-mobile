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

      // Parse all nodes from the list
      final List<OrganizationNode> allNodes = data
          .map((e) => OrganizationNode.fromJson(e as Map<String, dynamic>))
          .toList();

      // Find root nodes (nodes without a parent or with null parentId)
      final List<OrganizationNode> rootNodes = allNodes
          .where((node) => node.parentId == null || node.parentId!.isEmpty)
          .toList();

      if (rootNodes.isEmpty) {
        // If no root nodes found, use the first node as root
        rootNodes.add(allNodes.first);
      }

      // If there's only one root, return it directly
      if (rootNodes.length == 1) {
        return rootNodes.first;
      }

      // If multiple roots, create a virtual root node
      return OrganizationNode(
        id: 'root',
        name: 'Organizasyon',
        type: 'root',
        children: rootNodes,
      );
    }

    throw Exception('Beklenmeyen veri formatı: ${data.runtimeType}');
  }
}
