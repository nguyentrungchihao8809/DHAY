import 'package:dio/dio.dart';
import '../model/place_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/api_constants.dart';

abstract class PlaceRemoteDataSource {
  Future<List<PlaceModel>> searchPlaces(String query);
}

class MapboxPlaceRemoteDataSource implements PlaceRemoteDataSource {
  final Dio dio;

  MapboxPlaceRemoteDataSource({required this.dio});

  /// Chuẩn hóa query để Mapbox định hướng tốt hơn tại VN
  String _normalizeQuery(String query) {
    String q = query.trim();
    if (q.isEmpty) return "";

    // Nếu chưa có từ khóa định danh quốc gia, thêm vào để tăng độ chính xác
    if (!q.toLowerCase().contains("việt nam") && !q.toLowerCase().contains("vn")) {
      return "$q, Việt Nam";
    }
    return q;
  }

  @override
  Future<List<PlaceModel>> searchPlaces(String query) async {
    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) return [];

    try {
      // Encode query để tránh lỗi ký tự đặc biệt/tiếng Việt có dấu trên URL
      final encodedQuery = Uri.encodeComponent(normalizedQuery);
      final url = "${ApiConstants.mapboxBaseUrl}/$encodedQuery.json";

      final response = await dio.get(
        url,
        queryParameters: {
          'access_token': ApiConstants.mapboxToken,
          'country': 'VN',
          'language': 'vi',
          'types': 'poi,address,place', // poi: điểm đến, address: số nhà, place: phường/xã
          'bbox': '102.1446,8.1791,109.4646,23.3934', // Giới hạn trong lãnh thổ VN
          'proximity': '106.6297,10.8231', // Ưu tiên khu vực miền Nam/TP.HCM
          'autocomplete': 'true',
          'limit': 10,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final List features = response.data['features'];

        // Chuyển đổi List JSON sang List Model
        return features.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: "Lỗi kết nối Mapbox: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Xử lý lỗi riêng biệt của Dio (Network, Timeout, 401...)
      String errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } catch (e) {
      // Lỗi logic ngoài dự kiến
      throw ServerException(message: "Đã xảy ra lỗi: ${e.toString()}");
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Kết nối quá hạn, vui lòng kiểm tra mạng";
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) return "Token Mapbox không hợp lệ";
        return "Lỗi phản hồi từ server: ${e.response?.statusCode}";
      default:
        return "Lỗi kết nối không xác định";
    }
  }
}