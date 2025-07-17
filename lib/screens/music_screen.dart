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

class _MusicScreenState extends State<MusicScreen> {
  final Color pink = const Color(0xFFFF385D);

  final List<Song> songs = [
    Song(
      name: 'Imagine',
      artistName: 'John Lennon',
      albumImage: '',
      spotifyUri: 'spotify:track:7pKfPomDEeI4TPT6EOYjn9',
    ),
    Song(
      name: 'Bohemian Rhapsody',
      artistName: 'Queen',
      albumImage: '',
      spotifyUri: 'spotify:track:7tFiyTwD0nx5a1eklYtX2J',
    ),
    Song(
      name: 'Billie Jean',
      artistName: 'Michael Jackson',
      albumImage: '',
      spotifyUri: 'spotify:track:5ChkMS8OtdzJeqyybCc9R5',
    ),
  ];

  String? _spotifyToken;
  List<dynamic> _playlists = [];
  bool _isLoadingPlaylists = false;
  String? _playlistsError;

  @override
  void initState() {
    super.initState();
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

  // dart
  Future<void> _refreshPlaylists() async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    String? token = await musicProvider.getSpotifyAccessToken();

    if (token == null || token.isEmpty) {
      // Si no hay token, intenta reautenticar
      await musicProvider.initializeSpotify();
      token = await musicProvider.getSpotifyAccessToken();
    }

    try {
      final playlists = await musicProvider.fetchUserPlaylistsFromWebApi(token!);
      setState(() {
        _spotifyToken = token;
        _playlists = playlists;
        _playlistsError = null;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      // Si falla, intenta reautenticar y volver a cargar
      await musicProvider.initializeSpotify();
      token = await musicProvider.getSpotifyAccessToken();
      if (token != null && token.isNotEmpty) {
        try {
          final playlists = await musicProvider.fetchUserPlaylistsFromWebApi(token);
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
              labelColor: pink,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color
                  ?.withOpacity(0.6),
              indicatorColor: pink,
              tabs: const [
                Tab(text: 'Música'),
                Tab(text: 'Álbumes'),
                Tab(text: 'Playlists'),
                Tab(text: 'Importar'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildMusicTab(theme),
            _buildAlbumsTab(theme),
            _buildPlaylistsTab(theme),
            _buildImportTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicTab(ThemeData theme) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: songs.length,
          itemBuilder: (_, i) {
            final song = songs[i];
            return ListTile(
              leading: Icon(Icons.music_note, color: theme.iconTheme.color),
              title: Text(song.name, style: theme.textTheme.bodyLarge),
              subtitle: Text(
                song.artistName,
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Icon(
                Icons.play_arrow,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
              onTap: () {
                musicProvider.playSong(song);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab(ThemeData theme) =>
      Center(child: Text('Álbumes', style: theme.textTheme.bodyLarge));

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
                  onTap: () {
                    // Acción al tocar la playlist
                  },
                );
              },
            ),
    );
  }

  Widget _buildImportTab() => Center(
    child: ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: pink,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.file_upload),
      label: const Text('Importar MP3'),
    ),
  );
}
