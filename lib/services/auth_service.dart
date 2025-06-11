import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static late final Session session;

  static Future<bool> login(String identifier, String password) async {
    try {
      final response = await createSession(
        identifier: identifier,
        password: password,
      );
      session = response.data;
      print('Session data: ${jsonEncode(session)}');
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String email,
    required String handle,
    required String password,
  }) async {
    final url = Uri.parse('https://bsky.social/xrpc/com.atproto.server.createAccount');

    final body = jsonEncode({
      'email': email,
      'handle': handle,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Registro exitoso
        return true;
      } else {
        // Manejar errores
        print('Error en el registro: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante el registro: $e');
      return false;
    }
  }
}
