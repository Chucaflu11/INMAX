import 'package:flutter/foundation.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/song.dart';
import 'spotify_player.dart';
import 'dart:typed_data';

class MusicProvider with ChangeNotifier {
  final SpotifyPlayer _spotifyPlayer = SpotifyPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isConnected = false;
  bool _isLiked = false;
  bool _isRepeat = false;
  bool _isRepeatOne = false;
  bool _isShuffle = false;
  int _currentPosition = 0;
  int _duration = 0;
  int _currentTrackIndex = 0;
  List<dynamic> _currentPlaylistTracks = [];
  String? _currentPlaylistName;

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isConnected => _isConnected;
  bool get isLiked => _isLiked;
  bool get isRepeat => _isRepeat;
  bool get isRepeatOne => _isRepeatOne;
  bool get isShuffle => _isShuffle;
  int get currentPosition => _currentPosition;
  int get duration => _duration;
  double get progress => _duration > 0 ? _currentPosition / _duration : 0.0;
  List<dynamic> get currentPlaylistTracks => _currentPlaylistTracks;
  String? get currentPlaylistName => _currentPlaylistName;
  int get currentTrackIndex => _currentTrackIndex;


  // Inicializar conexión con Spotify
  Future<void> initializeSpotify() async {
    try {
      _isConnected = await _spotifyPlayer.connect();
      if (_isConnected) {
        _startListeningToPlayerState();
      }
      notifyListeners();
    } catch (e) {
      print('Error al inicializar Spotify: $e');
    }
  }

  // Reproducir canción
  Future<void> playSong(Song song) async {
    if (!_isConnected) return;

    try {
      // Encontrar el índice de la canción en la playlist actual
      if (_currentPlaylistTracks.isNotEmpty) {
        _currentTrackIndex = _currentPlaylistTracks.indexWhere(
              (item) => item['track']['uri'] == song.spotifyUri,
        );
        if (_currentTrackIndex == -1) _currentTrackIndex = 0;
      }

      await _spotifyPlayer.play(song.spotifyUri);
      _isPlaying = true;

      final playerState = await SpotifySdk.getPlayerState();
      if (playerState != null && playerState.track != null) {
        final track = playerState.track!;
        final imageBytes = await getImageFromTrack(track);

        _currentSong = Song(
          name: track.name,
          artistName: track.artist.name ?? '',
          albumImage: track.imageUri.raw,
          spotifyUri: track.uri,
          spotifyTrack: track,
          imageBytes: imageBytes,
        );
      } else {
        _currentSong = song;
      }

      notifyListeners();
    } catch (e) {
      print('Error al reproducir: $e');
    }
  }

  Future<void> _playTrackAtIndex(int index) async {
    if (_currentPlaylistTracks.isEmpty || index < 0 || index >= _currentPlaylistTracks.length) {
      return;
    }

    final track = _currentPlaylistTracks[index]['track'];
    final song = Song(
      name: track['name'] ?? '',
      artistName: track['artists'] != null && track['artists'].isNotEmpty
          ? track['artists'][0]['name']
          : '',
      albumImage: track['album']['images'] != null && track['album']['images'].isNotEmpty
          ? track['album']['images'][0]['url']
          : '',
      spotifyUri: track['uri'] ?? '',
    );

    _currentTrackIndex = index;
    await playSong(song);
  }

  void setCurrentPlaylist(List<dynamic> tracks, String? playlistName) {
    _currentPlaylistTracks = tracks;
    _currentPlaylistName = playlistName;
    _currentTrackIndex = 0;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (!_isConnected) return;

    try {
      if (_isPlaying) {
        await _spotifyPlayer.pause();
        _isPlaying = false;
      } else {
        await _spotifyPlayer.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error en toggle play/pause: $e');
    }
  }

  Future<void> skipNext() async {
    if (!_isConnected || _currentPlaylistTracks.isEmpty) return;

    int nextIndex;
    if (_isShuffle) {
      // Modo aleatorio: seleccionar índice aleatorio
      nextIndex = (DateTime.now().millisecondsSinceEpoch % _currentPlaylistTracks.length);
    } else {
      // Modo normal: siguiente canción
      nextIndex = _currentTrackIndex + 1;
      if (nextIndex >= _currentPlaylistTracks.length) {
        if (_isRepeat) {
          nextIndex = 0; // Volver al inicio si está en modo repeat
        } else {
          return; // No hacer nada si llegamos al final sin repeat
        }
      }
    }

    await _playTrackAtIndex(nextIndex);
  }

  Future<void> skipPrevious() async {
    if (!_isConnected || _currentPlaylistTracks.isEmpty) return;

    int prevIndex;
    if (_isShuffle) {
      // Modo aleatorio: seleccionar índice aleatorio
      prevIndex = (DateTime.now().millisecondsSinceEpoch % _currentPlaylistTracks.length);
    } else {
      // Modo normal: canción anterior
      prevIndex = _currentTrackIndex - 1;
      if (prevIndex < 0) {
        if (_isRepeat) {
          prevIndex = _currentPlaylistTracks.length - 1; // Ir al final si está en modo repeat
        } else {
          return; // No hacer nada si estamos al inicio sin repeat
        }
      }
    }

    await _playTrackAtIndex(prevIndex);
  }

  // Buscar a posición específica
  Future<void> seekTo(int positionMs) async {
    if (!_isConnected) return;
    await _spotifyPlayer.seekTo(positionMs);
  }

  // Escuchar estado del reproductor
  void _startListeningToPlayerState() {
    SpotifySdk.subscribePlayerState().listen((playerState) async {
      if (playerState.track != null) {
        final track = playerState.track!;
        String albumImageUrl = '';
        Uint8List? imageBytes;

        try {
          imageBytes = await SpotifySdk.getImage(
            imageUri: track.imageUri,
            dimension: ImageDimension.large,
          );
        } catch (e) {
          print('Error al cargar imagen con SDK: $e');
          if (track.imageUri.raw.isNotEmpty) {
            if (track.imageUri.raw.startsWith('spotify:image:')) {
              final imageId = track.imageUri.raw.split(':').last;
              albumImageUrl = 'https://i.scdn.co/image/$imageId';
            }
          }
        }

        _currentSong = Song(
          name: track.name,
          artistName: track.artist.name ?? '',
          albumImage: albumImageUrl.isEmpty ? track.imageUri.raw : albumImageUrl,
          spotifyUri: track.uri,
          spotifyTrack: track,
          imageBytes: imageBytes,
        );
      }

      bool wasPlaying = _isPlaying;
      _isPlaying = !playerState.isPaused;
      _currentPosition = playerState.playbackPosition;
      _duration = playerState.track?.duration ?? 0;

      // Detectar fin de canción y avanzar automáticamente
      if (wasPlaying && !_isPlaying && _currentPosition >= _duration - 1000 && _duration > 0) {
        if (_isRepeatOne) {
          // Repetir la misma canción
          await playSong(_currentSong!);
        } else {
          // Avanzar a la siguiente canción de la playlist
          await skipNext();
        }
      }

      notifyListeners();
    });
  }

  Future<Uint8List?> getImageFromTrack(Track track) async {
    try {
      return await SpotifySdk.getImage(
        imageUri: track.imageUri,
        dimension: ImageDimension.large,
      );
    } catch (e) {
      print('Error al obtener imagen: $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchPlaylistTracksFromWebApi(String token, String playlistId) async {
    final url = Uri.parse("https://api.spotify.com/v1/playlists/$playlistId/tracks");
    final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["items"];
    } else {
      throw Exception("Error al obtener canciones de la playlist: ${response.statusCode}");
    }
  }

  Future<List<dynamic>> fetchUserPlaylistsFromWebApi(String token) async {
    final url = Uri.parse("https://api.spotify.com/v1/me/playlists");
    final response = await http.get(url, headers: {"Authorization": "Bearer " + token});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["items"];
    } else {
      throw Exception("Error al obtener playlists: ${response.statusCode}");
    }
  }

  Future<String?> getSpotifyAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SpotifyPlayer.accessTokenKey);
  }

  // Toggle modes
  void toggleLike() {
    _isLiked = !_isLiked;
    notifyListeners();
  }

  // Modo shuffle personalizado para la playlist
  void setShuffleMode() async {
    if (!_isConnected) return;
    _isShuffle = !_isShuffle;
    // No usar el shuffle de Spotify
    notifyListeners();
  }


  // Modo repeat personalizado para la playlist
  void setRepeatMode() async {
    if (!_isConnected) return;
    _isRepeat = !_isRepeat;
    _isRepeatOne = false; // Desactivar repeat one si se activa repeat
    // No usar el repeat de Spotify
    notifyListeners();
  }

  void setRepeatOneMode() {
    _isRepeatOne = !_isRepeatOne;
    _isRepeat = false; // Desactivar repeat si se activa repeat one
    notifyListeners();
  }
}
