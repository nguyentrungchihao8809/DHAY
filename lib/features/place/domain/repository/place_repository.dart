import '../entity/place_entity.dart';

abstract class PlaceRepository {
  /// Tìm kiếm danh sách địa điểm từ một từ khóa (query)
  Future<List<PlaceEntity>> searchPlaces(String query);

// Bạn có thể thêm các hàm khác sau này như:
// Future<PlaceEntity> getPlaceDetails(String placeId);
}