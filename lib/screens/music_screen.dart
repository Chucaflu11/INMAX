import 'package:flutter/material.dart';
import 'package:inmax/providers/spotify_player.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin {
  final Color pink = const Color(0xFFFF385D);

  String? _spotifyToken;
  List<dynamic> _playlists = [];
  bool _isLoadingPlaylists = false;
  String? _playlistsError;

  List<dynamic> _selectedPlaylistTracks = [];
  String? _selectedPlaylistName;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => Provider.of<MusicProvider>(
        context,
        listen: false,
      ).initializeSpotify(),
    );
    _loadTokenAndPlaylists();
  }

  Future<void> _loadTokenAndPlaylists() async {
    setState(() {
      _isLoadingPlaylists = true;
      _playlistsError = null;
    });
    try {
      final token = await Provider.of<MusicProvider>(
        context,
        listen: false,
      ).getSpotifyAccessToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _spotifyToken = null;
          _playlists = [];
          _playlistsError = 'Token no disponible';
          _isLoadingPlaylists = false;
        });
        return;
      }
      final playlists = await Provider.of<MusicProvider>(
        context,
        listen: false,
      ).fetchUserPlaylistsFromWebApi(token);
      setState(() {
        _spotifyToken = token;
        _playlists = playlists;
        _playlistsError = null;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      setState(() {
        _playlistsError = 'Error al cargar playlists: $e';
        _isLoadingPlaylists = false;
      });
    }
  }

  Future<void> _refreshPlaylists() async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    String? token = await musicProvider.getSpotifyAccessToken();

    if (token == null || token.isEmpty) {
      await musicProvider.initializeSpotify();
      token = await musicProvider.getSpotifyAccessToken();
    }

    try {
      final playlists = await musicProvider.fetchUserPlaylistsFromWebApi(
        token!,
      );
      setState(() {
        _spotifyToken = token;
        _playlists = playlists;
        _playlistsError = null;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      await musicProvider.initializeSpotify();
      token = await musicProvider.getSpotifyAccessToken();
      if (token != null && token.isNotEmpty) {
        try {
          final playlists = await musicProvider.fetchUserPlaylistsFromWebApi(
            token,
          );
          setState(() {
            _spotifyToken = token;
            _playlists = playlists;
            _playlistsError = null;
            _isLoadingPlaylists = false;
          });
        } catch (e) {
          setState(() {
            _playlistsError = 'Error al cargar playlists: $e';
            _isLoadingPlaylists = false;
          });
        }
      } else {
        setState(() {
          _playlistsError = 'No se pudo obtener un token válido';
          _isLoadingPlaylists = false;
        });
      }
    }
  }

  Future<void> _selectPlaylist(Map playlist) async {
    setState(() {
      _isLoadingPlaylists = true;
      _selectedPlaylistTracks = [];
      _selectedPlaylistName = playlist['name'];
    });
    try {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      final token = await musicProvider.getSpotifyAccessToken();
      final playlistId = playlist['id'];
      final tracks = await musicProvider.fetchPlaylistTracksFromWebApi(
        token!,
        playlistId,
      );
      setState(() {
        _selectedPlaylistTracks = tracks;
        _isLoadingPlaylists = false;
      });

      // Pasar la playlist al provider
      musicProvider.setCurrentPlaylist(tracks, playlist['name']);

      _tabController.animateTo(0); // Ir a la pestaña de música
    } catch (e) {
      setState(() {
        _playlistsError = 'Error al cargar canciones de la playlist: $e';
        _isLoadingPlaylists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              labelColor: pink,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color
                  ?.withOpacity(0.6),
              indicatorColor: pink,
              tabs: const [
                Tab(text: 'Música'),
                Tab(text: 'Playlists'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildMusicTab(theme), _buildPlaylistsTab(theme)],
        ),
      ),
    );
  }

  Widget _buildMusicTab(ThemeData theme) {
    if (_selectedPlaylistTracks.isEmpty) {
      return Center(
        child: Text('Elegir playlist', style: theme.textTheme.bodyLarge),
      );
    }
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        // Calcular padding inferior basado en si hay canción reproduciéndose
        final bottomPadding = musicProvider.currentSong != null ? 80.0 : 16.0;

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
          itemCount: _selectedPlaylistTracks.length,
          itemBuilder: (_, i) {
            final track = _selectedPlaylistTracks[i]['track'];
            return ListTile(
              leading:
                  track['album']['images'] != null &&
                      track['album']['images'].isNotEmpty
                  ? Image.network(
                      track['album']['images'][0]['url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.music_note),
              title: Text(
                track['name'] ?? '',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                track['artists'] != null && track['artists'].isNotEmpty
                    ? track['artists'][0]['name']
                    : '',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Icon(
                Icons.play_arrow,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
              onTap: () {
                final song = Song(
                  name: track['name'] ?? '',
                  artistName:
                      track['artists'] != null && track['artists'].isNotEmpty
                      ? track['artists'][0]['name']
                      : '',
                  albumImage:
                      track['album']['images'] != null &&
                          track['album']['images'].isNotEmpty
                      ? track['album']['images'][0]['url']
                      : '',
                  spotifyUri: track['uri'] ?? '',
                );
                musicProvider.playSong(song);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshPlaylists,
      child: _isLoadingPlaylists
          ? const Center(child: CircularProgressIndicator())
          : _playlistsError != null
          ? ListView(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_playlistsError!, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshPlaylists,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _playlists.isEmpty
          ? ListView(
              children: [
                Center(
                  child: Text(
                    'No hay playlists disponibles',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _playlists.length,
              itemBuilder: (context, index) {
                final playlist = _playlists[index];
                final imageUrl =
                    (playlist['images'] != null &&
                        playlist['images'].isNotEmpty)
                    ? playlist['images'][0]['url']
                    : null;
                return ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.music_note),
                  title: Text(
                    playlist['name'] ?? 'Sin nombre',
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    playlist['description'] ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () => _selectPlaylist(playlist),
                );
              },
            ),
    );
  }
}
