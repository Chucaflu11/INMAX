import 'user_model.dart';

class AuthResponse {
  final String accessJwt;
  final String refreshJwt;
  final User user;

  AuthResponse({
    required this.accessJwt,
    required this.refreshJwt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map json) {
    return AuthResponse(
      accessJwt: json['accessJwt'] ?? '',
      refreshJwt: json['refreshJwt'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({required this.identifier, required this.password});

  Map toJson() {
    return {'identifier': identifier, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String handle;
  final String password;
  final String? inviteCode;

  RegisterRequest({
    required this.email,
    required this.handle,
    required this.password,
    this.inviteCode,
  });

  Map toJson() {
    return {
      'email': email,
      'handle': handle,
      'password': password,
      if (inviteCode != null) 'inviteCode': inviteCode,
    };
  }
}
