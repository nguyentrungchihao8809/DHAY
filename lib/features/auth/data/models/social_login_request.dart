class SocialLoginRequest {
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String identifier;
  final String provider; // 'GOOGLE' hoặc 'FACEBOOK'

  SocialLoginRequest({
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.identifier,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'identifier': identifier,
      'provider': provider,
    };
  }
}