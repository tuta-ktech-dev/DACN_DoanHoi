class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final token = json['access_token'] ?? json['token'] ?? data['token'] ?? '';
    final refresh = json['refresh_token'] ?? '';
    final expires = json['expires_at'] ?? DateTime.now().toIso8601String();
    return AuthResponse(
      accessToken: token,
      refreshToken: refresh,
      expiresAt: DateTime.tryParse(expires) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
