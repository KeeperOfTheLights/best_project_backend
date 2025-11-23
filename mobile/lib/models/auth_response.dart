import 'user.dart';

// AuthResponse model - what we get back from login/signup API
class AuthResponse {
  final String token;
  final String? refreshToken; // Refresh token for token renewal
  final User user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  // Convert JSON from backend to AuthResponse object
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refresh'], // Backend returns 'refresh' field
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}




