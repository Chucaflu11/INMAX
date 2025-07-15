import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Session? session;

  static Future<bool> login(String identifier, String password) async {
    try {
      final response = await createSession(
        identifier: identifier,
        password: password,
      );
      session = response.data;

      // Guardar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('identifier', identifier);
      await prefs.setString('accessJwt', session!.accessJwt);
      await prefs.setString('refreshJwt', session!.refreshJwt);
      await prefs.setString('handle', session!.handle);
      await prefs.setString('did', session!.did);

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
        return true;
      } else {
        print('Error en el registro: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante el registro: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool('isLoggedIn') ?? false;

    if (isLogged) {
      final accessJwt = prefs.getString('accessJwt');
      final refreshJwt = prefs.getString('refreshJwt');
      final handle = prefs.getString('handle');
      final did = prefs.getString('did');

      if (accessJwt != null && refreshJwt != null && handle != null && did != null) {
        session = Session(
          accessJwt: accessJwt,
          refreshJwt: refreshJwt,
          handle: handle,
          did: did,
        );
      }
    }

    return isLogged;
  }

  static Session? getSession() => session;

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessJwt');
  }
}
