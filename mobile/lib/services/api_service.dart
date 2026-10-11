import '../models/models.dart';
import 'local_catalog.dart';

/// Fonte de dados do app: lê o catálogo embutido em [LocalCatalog].
class ApiService {
  Future<List<Area>> fetchAreas() => LocalCatalog.areas();

  Future<List<ClubSummary>> fetchClubsByArea(String areaId) =>
      LocalCatalog.clubsByArea(areaId);

  Future<ClubDetail> fetchClub(String clubId) => LocalCatalog.clubById(clubId);
}
