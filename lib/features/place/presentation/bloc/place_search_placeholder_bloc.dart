import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/place_entity.dart';
import '../../domain/usecase/search_place_usecase.dart';

/// ================= ENUM =================
enum LocationFieldType { pickup, dropoff }

/// ================= EVENTS =================
abstract class PlaceSearchEvent {}

class SearchQueryChanged extends PlaceSearchEvent {
  final String query;
  final LocationFieldType fieldType;
  SearchQueryChanged(this.query, this.fieldType);
}

class _FetchPlacesInternal extends PlaceSearchEvent {
  final String query;
  final LocationFieldType fieldType;
  _FetchPlacesInternal(this.query, this.fieldType);
}

// Event khi người dùng nhấn chọn một địa điểm để gửi về Spring Boot
class SelectPlaceEvent extends PlaceSearchEvent {
  final PlaceEntity place;
  SelectPlaceEvent(this.place);
}

/// ================= STATES =================
abstract class PlaceSearchState {}

class PlaceSearchInitial extends PlaceSearchState {}

// Cải tiến: Loading vẫn mang theo dữ liệu cũ để tránh trắng màn hình
class PlaceSearchLoading extends PlaceSearchState {
  final List<PlaceEntity> pickupPlaces;
  final List<PlaceEntity> dropoffPlaces;
  PlaceSearchLoading({this.pickupPlaces = const [], this.dropoffPlaces = const []});
}

class PlaceSearchLoaded extends PlaceSearchState {
  final List<PlaceEntity> pickupPlaces;
  final List<PlaceEntity> dropoffPlaces;
  final LocationFieldType lastModifiedField; // Quan trọng để UI biết hiển thị list nào

  PlaceSearchLoaded({
    this.pickupPlaces = const [],
    this.dropoffPlaces = const [],
    required this.lastModifiedField,
  });
}

class PlaceSearchError extends PlaceSearchState {
  final String message;
  PlaceSearchError(this.message);
}

/// ================= BLOC =================
class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  final SearchPlaceUseCase searchPlaceUseCase;
  Timer? _debounce;

  PlaceSearchBloc({required this.searchPlaceUseCase}) : super(PlaceSearchInitial()) {

    on<SearchQueryChanged>((event, emit) {
      _debounce?.cancel();
      if (event.query.isEmpty) {
        emit(PlaceSearchInitial());
        return;
      }
      _debounce = Timer(const Duration(milliseconds: 500), () {
        add(_FetchPlacesInternal(event.query, event.fieldType));
      });
    });

    on<_FetchPlacesInternal>((event, emit) async {
      // Giữ lại dữ liệu hiện tại khi đang load
      List<PlaceEntity> currentPickup = [];
      List<PlaceEntity> currentDropoff = [];

      if (state is PlaceSearchLoaded) {
        currentPickup = (state as PlaceSearchLoaded).pickupPlaces;
        currentDropoff = (state as PlaceSearchLoaded).dropoffPlaces;
      }

      emit(PlaceSearchLoading(pickupPlaces: currentPickup, dropoffPlaces: currentDropoff));

      try {
        final results = await searchPlaceUseCase(event.query);

        emit(PlaceSearchLoaded(
          pickupPlaces: event.fieldType == LocationFieldType.pickup ? results : currentPickup,
          dropoffPlaces: event.fieldType == LocationFieldType.dropoff ? results : currentDropoff,
          lastModifiedField: event.fieldType,
        ));
      } catch (e) {
        emit(PlaceSearchError("Lỗi kết nối Mapbox"));
      }
    });

    // Xử lý gửi dữ liệu về Backend (Bước 8 trong quy trình của bạn)
    on<SelectPlaceEvent>((event, emit) async {
      try {
        // Gọi hàm repository.saveToBackend(event.place) ở đây
        print("Đang gửi tới Spring Boot: ${event.place.name}");
      } catch (e) {
        print("Lỗi gửi BE: $e");
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}