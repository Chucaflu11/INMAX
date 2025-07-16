import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    const pink = Color(0xFFFF385D);

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => Container(
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
                  child: (musicProvider.currentSong != null)
                      ? musicProvider.currentSong!.imageBytes != null
                      ? Image.memory(
                    musicProvider.currentSong!.imageBytes!,
                    fit: BoxFit.cover,
                  )
                      : musicProvider.currentSong!.albumImage.isNotEmpty
                      ? Image.network(
                    musicProvider.currentSong!.albumImage,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, _) => Image.asset(
                      'assets/taxmanMockup.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/taxmanMockup.jpg',
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/taxmanMockup.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                musicProvider.currentSong?.name ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                musicProvider.currentSong?.artistName ?? '',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildControls(context, musicProvider),
              const SizedBox(height: 20),
              Slider(
                value: musicProvider.progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = (value * musicProvider.duration).round();
                  musicProvider.seekTo(newPosition);
                },
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
                    onTap: () => musicProvider.togglePlayPause(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: pink,
                      ),
                      child: Icon(
                        musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, MusicProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconButton(
          provider.isLiked ? Icons.favorite : Icons.favorite_border,
          provider,
          isActive: provider.isLiked,
          onTap: () => provider.toggleLike(),
        ),
        _iconButton(Icons.playlist_add, provider),
        _iconButton(
          Icons.repeat,
          provider,
          isActive: provider.isRepeat,
          onTap: () => provider.setRepeatMode(),
        ),
        _iconButton(
          Icons.repeat_one,
          provider,
          isActive: provider.isRepeatOne,
          onTap: () => provider.setRepeatOneMode(),
        ),
        _iconButton(
          Icons.shuffle,
          provider,
          isActive: provider.isShuffle,
          onTap: () => provider.setShuffleMode(),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, MusicProvider provider,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => provider.togglePlayPause(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? const Color(0xFFFF385D) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 22,
        ),
      ),
    );
  }
}
