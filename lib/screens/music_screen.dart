import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<MusicProvider>(
        context,
        listen: false,
      ).initializeSpotify(),
    );
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

  Widget _buildPlaylistsTab(ThemeData theme) =>
      Center(child: Text('Playlists', style: theme.textTheme.bodyLarge));

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
