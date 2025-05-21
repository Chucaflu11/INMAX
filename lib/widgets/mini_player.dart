import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/svg_icons.dart';
import '../constants/app_colors.dart';

class MiniPlayer extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const MiniPlayer({
    super.key,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onTogglePlay,
                splashRadius: 22,
                icon: SvgPicture.asset(
                  isPlaying ? SvgIcons.pause : SvgIcons.pause, // puedes reemplazar luego por play si tienes ese SVG
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                splashRadius: 22,
                icon: SvgPicture.asset(
                  isFavorite ? SvgIcons.like : SvgIcons.unlike,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isFavorite ? AppColors.pink : Colors.black45,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
