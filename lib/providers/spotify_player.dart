import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/connection_status.dart';

class SpotifyPlayer {
  static const String clientId = '46065490b0a74d70ab7568ce33b56d1f';
  static const String redirectUri = 'inmax://callback';

  Future<void> connect() async {
    try {
      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );

      if (connected) {
        print('🎵 Conectado a Spotify');
      } else {
        print('❌ No se pudo conectar');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
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
}
