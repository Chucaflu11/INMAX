import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({ApiService? apiService, StorageService? storageService})
    : _apiService = apiService ?? ApiService(),
      _storageService = storageService ?? StorageService() {
    _initializeAuthState();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Inicializar el estado de autenticación desde el almacenamiento local
  Future _initializeAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasSession = await _storageService.hasActiveSession();
      if (hasSession) {
        _currentUser = await _storageService.getUser();
        _accessToken = await _storageService.getAccessToken();
        _refreshToken = await _storageService.getRefreshToken();
      }
    } catch (e) {
      _errorMessage = "Error al inicializar la sesión";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrar un nuevo usuario
  Future register(String email, String handle, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final registerRequest = RegisterRequest(
        email: email,
        handle: handle,
        password: password,
      );

      final response = await _apiService.register(registerRequest);

      _accessToken = response.accessJwt;
      _refreshToken = response.refreshJwt;
      _currentUser = response.user;

      await _storageService.saveAuthData(
        response.accessJwt,
        response.refreshJwt,
        response.user,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión
  Future login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(
        identifier: identifier,
        password: password,
      );

      final response = await _apiService.login(loginRequest);

      _accessToken = response.accessJwt;
      _refreshToken = response.refreshJwt;
      _currentUser = response.user;

      await _storageService.saveAuthData(
        response.accessJwt,
        response.refreshJwt,
        response.user,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_accessToken != null) {
        await _apiService.logout(_accessToken!);
      }
    } catch (e) {
      // Incluso si falla la llamada al API, limpiamos los datos locales
    } finally {
      await _storageService.clearAuthData();
      _accessToken = null;
      _refreshToken = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refrescar token
  Future refreshTokenIfNeeded() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _apiService.refreshToken(_refreshToken!);

      _accessToken = response.accessJwt;
      _refreshToken = response.refreshJwt;

      await _storageService.updateTokens(
        response.accessJwt,
        response.refreshJwt,
      );

      return true;
    } catch (e) {
      // Si falla el refresco, forzamos logout
      await logout();
      return false;
    }
  }

  // Obtener token de acceso con refresco automático si es necesario
  Future getValidAccessToken() async {
    if (_accessToken == null) return null;

    // Aquí se podría implementar lógica para verificar si el token está por expirar
    // y refrescarlo automáticamente si es necesario

    return _accessToken;
  }
}
