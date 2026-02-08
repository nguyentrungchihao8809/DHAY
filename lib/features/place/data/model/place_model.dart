// lib/features/place/data/model/place_model.dart
import '../../domain/entity/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
    required super.name,
    required super.lat,
    required super.lng,
  });

  // Chuyển đổi từ JSON của Mapbox sang Model
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Mapbox trả về tọa độ trong: geometry -> coordinates -> [lng, lat]
    final List<dynamic> coordinates = json['geometry']['coordinates'];

    return PlaceModel(
      // Mapbox trả về tên đầy đủ trong 'place_name'
      name: json['place_name'] ?? '',
      // index 0 là Kinh độ (Longitude)
      lng: (coordinates[0] as num).toDouble(),
      // index 1 là Vĩ độ (Latitude)
      lat: (coordinates[1] as num).toDouble(),
    );
  }

  // Chuyển từ Model sang JSON (Dùng khi cần gửi DTO về Backend của bạn)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
    };
  }
}