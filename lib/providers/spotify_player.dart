import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyPlayer {
  static const String clientId = '301d702be72a4154b26818f6c79cfdae';
  static const String redirectUri = 'com.example.inmax://callback';
  static const String accessTokenKey = 'spotify_access_token'; //placeholder

  Future<void> _saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, token);
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  Future<bool> connect() async {
    try {
      // Intenta conectar con un token guardado
      String? accessToken = await _getAccessToken();
      if (accessToken != null) {
        final connected = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientId,
          redirectUrl: redirectUri,
          accessToken: accessToken,
        );
        if (connected) {
          print('Conectado usando token guardado');
          return true;
        }
        print(
          'El token guardado no funcionó, se necesita nueva autenticación.',
        );
      }

      // Si no hay token o falló, autenticar para obtener uno nuevo
      return await authenticateAndConnect();
    } catch (e) {
      print('❌ Error de conexión: $e');
      // Si hay un error, podría ser por un token inválido. Forzar re-autenticación.
      return await authenticateAndConnect();
    }
  }

  Future<bool> authenticateAndConnect() async {
    try {
      final accessToken = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUri,
        scope: 'app-remote-control,user-modify-playback-state,playlist-read-private',
      );

      if (accessToken.isNotEmpty) {
        await _saveAccessToken(accessToken); // Guarda el nuevo token
        print('Usuario autenticado y token guardado.');

        final connected = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientId,
          redirectUrl: redirectUri,
          accessToken: accessToken,
        );

        if (connected) {
          print('Conectado a Spotify');
          return true;
        }
      }
      print('❌ No se pudo obtener el token de acceso.');
      return false;
    } catch (e) {
      print('❌ Error en authenticateAndConnect: $e');
      return false;
    }
  }

  Future<void> play(String uri) async {
    try {
      await SpotifySdk.play(spotifyUri: uri);
      print('▶️ Reproduciendo $uri');
    } catch (e) {
      print('❌ Error al reproducir: $e');
      await authenticateAndConnect();
    }
  }

  Future<void> pause() async {
    await SpotifySdk.pause();
  }

  Future<void> resume() async {
    await SpotifySdk.resume();
  }

  Future<void> skipNext() async {
    await SpotifySdk.skipNext();
  }

  Future<void> skipPrevious() async {
    await SpotifySdk.skipPrevious();
  }

  Future<void> seekTo(int positionMs) async {
    await SpotifySdk.seekToRelativePosition(relativeMilliseconds: positionMs);
  }

  Future<void> setShuffle(bool shuffle) async {
    await SpotifySdk.setShuffle(shuffle: shuffle);
  }

  Future<void> setRepeatMode(bool repeat) async {
    await SpotifySdk.setRepeatMode(
      repeatMode: repeat ? RepeatMode.track : RepeatMode.off,
    );
  }

  Future<void> disconnect() async {
    await SpotifySdk.disconnect();
  }
}
