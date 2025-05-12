import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Función para registrar un nuevo usuario
  Future register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/register'),
        headers: ApiConfig.headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error en el registro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falló la conexión al servidor: $e');
    }
  }

  // Función para iniciar sesión
  Future login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/login'),
        headers: ApiConfig.headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error en el inicio de sesión: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falló la conexión al servidor: $e');
    }
  }

  // Función para obtener el perfil del usuario
  Future getUserProfile(String did, String accessToken) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/profile/$did'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener el perfil: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falló la conexión al servidor: $e');
    }
  }

  // Función para refrescar el token
  Future refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/refresh'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al refrescar el token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falló la conexión al servidor: $e');
    }
  }

  // Función para cerrar sesión
  Future logout(String accessToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/logout'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cerrar sesión: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falló la conexión al servidor: $e');
    }
  }
}
