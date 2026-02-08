import '../../domain/entity/place_entity.dart';
import '../../domain/repository/place_repository.dart';
import '../datasources/mapbox_place_remote.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final MapboxPlaceRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlaceEntity>> searchPlaces(String query) async {
    // Gọi API từ DataSource, tự động trả về List<PlaceModel>
    // Vì PlaceModel kế thừa từ PlaceEntity nên kiểu dữ liệu sẽ khớp
    return await remoteDataSource.searchPlaces(query);
  }
}