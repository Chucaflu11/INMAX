import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'music_player.dart';

class MiniMusicPlayer extends StatelessWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    if (musicProvider.currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const MusicPlayer(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF385D), Color(0xFF591421)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musicProvider.currentSong?.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    musicProvider.currentSong?.artistName ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () => musicProvider.togglePlayPause(),
            ),
          ],
        ),
      ),
    );
  }
}
