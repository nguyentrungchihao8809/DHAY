import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/social_login_request.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> login(String identifier, String password);
  Future<UserModel> register(String fullName, String identifier, String password);
  Future<UserModel> socialLogin(SocialLoginRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String identifier, String password) async {
    final response = await client.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'provider': 'LOCAL', // Khớp với LoginRequest BE
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(); // Em nhớ định nghĩa trong core/errors nhé
    }
  }

  @override
  Future<UserModel> register(String fullName, String identifier, String password) async {
    final response = await client.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,   // Đảm bảo key này khớp với field trong RegisterRequest.java
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      // Nếu @Valid ở Backend bắt lỗi (ví dụ mật khẩu quá ngắn), nó sẽ trả về lỗi ở đây
      throw ServerException(message: "Đăng ký thất bại: ${response.body}");
    }
  }
  @override
  Future<UserModel> socialLogin(SocialLoginRequest request) async {
    final response = await client.post(
      Uri.parse(ApiConstants.socialLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: "Lỗi đăng nhập mạng xã hội");
    }
  }
}