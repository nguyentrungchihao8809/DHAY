import '../repository/place_repository.dart';
import '../entity/place_entity.dart';

class SearchPlaceUseCase {
  final PlaceRepository repository;

  SearchPlaceUseCase(this.repository);

  Future<List<PlaceEntity>> call(String query) async {
    if (query.isEmpty) return [];
    return await repository.searchPlaces(query);
  }
}