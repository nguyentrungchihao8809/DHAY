import '../../../../core/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  // Constructor gọi đến super với các tham số tương ứng
  UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Chú ý: Key 'id', 'fullName', 'email' phải khớp 100% với JSON BE trả về
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      token: json['accessToken'] ?? '',
    );
  }

  // Bonus: Hàm này giúp ích khi cần gửi data ngược lại BE
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'accessToken': token,
    };
  }
}