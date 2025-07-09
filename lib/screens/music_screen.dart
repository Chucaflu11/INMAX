import 'package:flutter/material.dart';
import '../providers/spotify_player.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final Color pink = const Color(0xFFFF385D);
  final SpotifyPlayer spotifyPlayer = SpotifyPlayer();

  final List<Map<String, String>> songs = [
    {
      'title': 'Imagine',
      'artist': 'John Lennon',
      'uri': 'spotify:track:7pKfPomDEeI4TPT6EOYjn9',
    },
    {
      'title': 'Bohemian Rhapsody',
      'artist': 'Queen',
      'uri': 'spotify:track:7tFiyTwD0nx5a1eklYtX2J',
    },
    {
      'title': 'Billie Jean',
      'artist': 'Michael Jackson',
      'uri': 'spotify:track:5ChkMS8OtdzJeqyybCc9R5',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => spotifyPlayer.connect());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SafeArea(
            child: TabBar(
              labelColor: pink,
              unselectedLabelColor: Colors.black54,
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
            _buildMusicTab(),
            _buildAlbumsTab(),
            _buildPlaylistsTab(),
            _buildImportTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        return ListTile(
          leading: const Icon(Icons.music_note, color: Colors.black54),
          title: Text(
            song['title']!,
            style: const TextStyle(color: Colors.black87),
          ),
          subtitle: Text(
            song['artist']!,
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: const Icon(Icons.play_arrow, color: Colors.black38),
          onTap: () {
            spotifyPlayer.play(song['uri']!);
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() => Center(
        child: Text('Álbumes', style: TextStyle(color: Colors.black)),
      );

  Widget _buildPlaylistsTab() => Center(
        child: Text('Playlists', style: TextStyle(color: Colors.black)),
      );

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
