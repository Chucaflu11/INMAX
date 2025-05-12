import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _tokenExpiryKey = 'token_expiry';

  // Guardar tokens y datos de usuario
  Future saveAuthData(
    String accessToken,
    String refreshToken,
    User user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    // Establecer tiempo de expiración del token (ejemplo: 2 horas)
    final expiry =
        DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch;
    await prefs.setInt(_tokenExpiryKey, expiry);
  }

  // Obtener token de acceso
  Future getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Obtener token de refresco
  Future getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Obtener datos del usuario
  Future getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Verificar si hay una sesión activa
  Future hasActiveSession() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    // Verificar si el token ha expirado
    final isExpired = await isTokenExpired();
    return !isExpired;
  }

  // Verificar si el token ha expirado
  Future isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_tokenExpiryKey);
    if (expiry == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiry;
  }

  // Eliminar datos de sesión
  Future clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenExpiryKey);
  }

  // Actualizar tokens
  Future updateTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    // Actualizar tiempo de expiración
    final expiry =
        DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch;
    await prefs.setInt(_tokenExpiryKey, expiry);
  }
}
