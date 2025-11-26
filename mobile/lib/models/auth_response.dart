import 'user.dart';

class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refresh'],
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}




