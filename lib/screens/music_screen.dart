import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final Color pink = const Color(0xFFFF385D);

  final List<String> songs = [
    'Yesterday.mp3',
    'Come Together.mp3',
    'Let It Be.mp3',
    'Hey Jude.mp3'
  ];
  final List<String> albums = ['Revolver', 'Abbey Road', 'Let It Be'];
  final List<String> playlists = ['Chill Vibes', 'Workout Mix', 'Beatles Favorites'];

  bool isLiked = false;
  bool isShuffling = false;
  bool isRepeating = false;
  bool isRepeatOne = false;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLiked = prefs.getBool('isLiked') ?? false;
      isShuffling = prefs.getBool('isShuffling') ?? false;
      isRepeating = prefs.getBool('isRepeating') ?? false;
      isRepeatOne = prefs.getBool('isRepeatOne') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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

  Widget _buildFullPlayerContent(ScrollController controller, void Function(void Function()) modalSetState) {
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
              child: Image.asset(
                'assets/taxmanMockup.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Taxman',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'The Beatles',
            style: TextStyle(color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                active: isLiked,
                onTap: () => modalSetState(() {
                  isLiked = !isLiked;
                  _savePreference('isLiked', isLiked);
                }),
              ),
              _buildIconButton(
                icon: Icons.playlist_add,
                active: false,
                onTap: () {},
              ),
              _buildIconButton(
                icon: Icons.repeat,
                active: isRepeating,
                onTap: () => modalSetState(() {
                  isRepeating = true;
                  isRepeatOne = false;
                  isShuffling = false;
                  _savePreference('isRepeating', true);
                  _savePreference('isRepeatOne', false);
                  _savePreference('isShuffling', false);
                }),
              ),
              _buildIconButton(
                icon: Icons.repeat_one,
                active: isRepeatOne,
                onTap: () => modalSetState(() {
                  isRepeatOne = true;
                  isRepeating = false;
                  isShuffling = false;
                  _savePreference('isRepeatOne', true);
                  _savePreference('isRepeating', false);
                  _savePreference('isShuffling', false);
                }),
              ),
              _buildIconButton(
                icon: Icons.shuffle,
                active: isShuffling,
                onTap: () => modalSetState(() {
                  isShuffling = true;
                  isRepeating = false;
                  isRepeatOne = false;
                  _savePreference('isShuffling', true);
                  _savePreference('isRepeating', false);
                  _savePreference('isRepeatOne', false);
                }),
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
                onTap: () => modalSetState(() => isPlaying = !isPlaying),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pink,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
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

  Widget _buildMusicTab() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: songs.length,
    itemBuilder: (_, i) => ListTile(
      leading: const Icon(Icons.music_note, color: Colors.black54),
      title: Text(songs[i], style: const TextStyle(color: Colors.black87)),
      trailing: const Icon(Icons.more_vert, color: Colors.black38),
      onTap: () {},
    ),
  );

  Widget _buildAlbumsTab() => GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: albums.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
    ),
    itemBuilder: (_, i) => Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(albums[i], style: const TextStyle(color: Colors.black)),
      ),
    ),
  );

  Widget _buildPlaylistsTab() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: playlists.length,
    itemBuilder: (_, i) => Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.playlist_play, color: Colors.black),
        title: Text(playlists[i], style: const TextStyle(color: Colors.black87)),
        onTap: () {},
      ),
    ),
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
