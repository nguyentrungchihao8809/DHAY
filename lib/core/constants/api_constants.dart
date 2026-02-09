// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String mapboxToken = 'pk.eyJ1IjoidHJ1bmdjaGloYW8iLCJhIjoiY21rYzRid2RlMGF2YzNucG8yM3h4cTZzYyJ9.62ETdJoM5foxkcPAxFe7Wg';
  static const String mapboxBaseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  static const String backendUrl = 'http://192.168.1.5:8080/api/locations';
  // static const String backendUrl = 'http://10.0.2.2:8080/api/locations';
  //thay đổi quan lại

  // Base URL gốc của server
  static const String baseUrl = "http://192.168.1.250:8080/api";

  // Tầng Version
  static const String v1 = "$baseUrl/v1";

  // Các Resource/Feature (Auth, Ride, Map...)
  static const String auth = "$v1/auth";

  // Chi tiết từng API endpoint
  static const String login = "$auth/login";
  static const String register = "$auth/register";
  static const String socialLogin = "$auth/social-login";
}
