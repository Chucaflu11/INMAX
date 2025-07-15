import 'package:flutter/foundation.dart';
  import 'package:spotify_sdk/spotify_sdk.dart';
  import '../models/song.dart';
  import 'spotify_player.dart';

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
        _currentSong = song;
        await _spotifyPlayer.play(song.spotifyUri);
        _isPlaying = true;
        notifyListeners();
      } catch (e) {
        print('Error al reproducir: $e');
      }
    }

    // Toggle play/pause
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

    // Siguiente canción
    Future<void> skipNext() async {
      if (!_isConnected) return;
      await _spotifyPlayer.skipNext();
    }

    // Canción anterior
    Future<void> skipPrevious() async {
      if (!_isConnected) return;
      await _spotifyPlayer.skipPrevious();
    }

    // Buscar a posición específica
    Future<void> seekTo(int positionMs) async {
      if (!_isConnected) return;
      await _spotifyPlayer.seekTo(positionMs);
    }

    // Escuchar estado del reproductor
    void _startListeningToPlayerState() {
      SpotifySdk.subscribePlayerState().listen((playerState) {
        if (playerState.track != null) {
          _currentSong = Song(
            name: playerState.track!.name,
            artistName: playerState.track!.artist.name ?? '',
            albumImage: playerState.track!.imageUri.raw,
            spotifyUri: playerState.track!.uri,
          );
        }

        _isPlaying = !playerState.isPaused;
        _currentPosition = playerState.playbackPosition;
        _duration = playerState.track?.duration ?? 0;
        _isShuffle = playerState.playbackOptions.isShuffling;
        _isRepeat = playerState.playbackOptions.repeatMode != RepeatMode.off;

        notifyListeners();
      });
    }

    // Toggle modes
    void toggleLike() {
      _isLiked = !_isLiked;
      notifyListeners();
    }

    void setShuffleMode() async {
      if (!_isConnected) return;
      await _spotifyPlayer.setShuffle(!_isShuffle);
    }

    void setRepeatMode() async {
      if (!_isConnected) return;
      await _spotifyPlayer.setRepeatMode(!_isRepeat);
    }

    void setRepeatOneMode() {
      _isRepeatOne = !_isRepeatOne;
      notifyListeners();
    }
  }