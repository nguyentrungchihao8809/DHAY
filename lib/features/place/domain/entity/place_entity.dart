// lib/features/place/domain/entity/place_entity.dart
import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String name;
  final double lat;
  final double lng;

  const PlaceEntity({
    required this.name,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [name, lat, lng];
}