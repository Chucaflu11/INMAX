import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final Color pink = const Color(0xFFFF385D);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<MusicProvider>(
        context,
        listen: false,
      ).fetchJamendoSongs(),
    );
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
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        if (musicProvider.jamendoSongs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musicProvider.jamendoSongs.length,
          itemBuilder: (_, i) {
            final song = musicProvider.jamendoSongs[i];
            return ListTile(
              leading: song.albumImage.isNotEmpty
                  ? Image.network(
                      song.albumImage,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.music_note, color: Colors.black54),
              title: Text(
                song.name,
                style: const TextStyle(color: Colors.black87),
              ),
              subtitle: Text(
                song.artistName,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.more_vert, color: Colors.black38),
              onTap: () {
                musicProvider.setSong(song);
                _showFullPlayer();
              },
            );
          },
        );
      },
    );
  }

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.3,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, controller) {
                return SafeArea(
                  top: false,
                  child: _buildFullPlayerContent(controller, modalSetState),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFullPlayerContent(
    ScrollController controller,
    void Function(void Function()) modalSetState,
  ) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final song = musicProvider.currentSong;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView(
        controller: controller,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: song != null && song.albumImage.isNotEmpty
                  ? Image.network(song.albumImage, fit: BoxFit.cover)
                  : Image.asset('assets/taxmanMockup.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            song?.name ?? 'Sin título',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            song?.artistName ?? 'Desconocido',
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                icon: Icons.favorite_border,
                active: false,
                onTap: () {},
              ),
              _buildIconButton(
                icon: Icons.playlist_add,
                active: false,
                onTap: () {},
              ),
              _buildIconButton(icon: Icons.repeat, active: false, onTap: () {}),
              _buildIconButton(
                icon: Icons.repeat_one,
                active: false,
                onTap: () {},
              ),
              _buildIconButton(
                icon: Icons.shuffle,
                active: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Slider(
            value: 0.3,
            onChanged: (v) {},
            activeColor: pink,
            inactiveColor: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.black),
                onPressed: () {},
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pink,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? pink : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.black,
          size: 24,
        ),
      ),
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
