// Stub for web platform

class ElevatorAuth {
  final dynamic device;
  ElevatorAuth({required this.device});

  Future<bool> initialize() async => false;

  Future<AuthResult> authenticate({
    required String qrToken,
    required String deviceId,
    String? userId,
  }) async {
    return AuthResult.failure('Authentication not supported on web');
  }

  void dispose() {}
}

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? sessionToken;

  AuthResult._({required this.success, this.errorMessage, this.sessionToken});

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(success: false, errorMessage: errorMessage);
  }

  bool get isAuthenticated => false;
}
