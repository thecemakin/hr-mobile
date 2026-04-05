import '../../domain/models/organization.dart';
import '../api/organization_service.dart';

class OrganizationRepository {
  final OrganizationService _organizationService;

  OrganizationRepository({required OrganizationService organizationService})
    : _organizationService = organizationService;

  Future<OrganizationNode> getOrganizationTree() {
    return _organizationService.getOrganizationTree();
  }
}
