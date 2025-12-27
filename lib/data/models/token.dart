/// Local auth token model used by `StorageService`.
///
/// Note: This is not a Supabase table model; it exists because parts of the app
/// expect `Tokens` to be persisted locally for request auth.
class Tokens {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn; // seconds

  const Tokens({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      expiresIn: json['expires_in'] is int
          ? json['expires_in'] as int
          : int.tryParse('${json['expires_in']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }

  Tokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) {
    return Tokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}
