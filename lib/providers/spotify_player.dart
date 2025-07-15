import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/connection_status.dart';

class SpotifyPlayer {
  static const String clientId = '301d702be72a4154b26818f6c79cfdae';
  static const String redirectUri = 'com.example.inmax://callback';

  Future<bool> authenticate() async {
    try {
      final accessToken = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUri,
        scope: 'app-remote-control,user-modify-playback-state'
      );

      if (accessToken != null && accessToken.isNotEmpty) {
        print(
          '🔐 Usuario autenticado con token: ${accessToken.substring(0, 10)}...',
        );
        return true;
      }
      print('❌ Token de autenticación vacío, $accessToken');
      return false;
    } catch (e) {
      print('❌ Error de autenticación: $e');
      return false;
    }
  }

  Future<bool> connect() async {
    try {
      // Primero autenticar
      final authenticated = await authenticate();
      if (!authenticated) {
        print('❌ Usuario no autenticado');
        return false;
      }

      // Luego conectar al App Remote
      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );

      if (connected) {
        print('🎵 Conectado a Spotify');
        return true;
      } else {
        print('❌ No se pudo conectar');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  Future<void> play(String uri) async {
    try {
      await SpotifySdk.play(spotifyUri: uri);
      print('▶️ Reproduciendo $uri');
    } catch (e) {
      print('❌ Error al reproducir: $e');
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
