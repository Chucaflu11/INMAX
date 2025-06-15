import 'dart:ui';
import 'package:flutter/material.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  bool isLiked = false;

  // Mockup data
  final String coverPath = 'assets/taxmanMockup.jpg';
  final String songTitle = 'Taxman';
  final String artist = 'The Beatles';

  double progress = 0.3; // 30% de progreso

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    final pink = const Color(0xFFFF385D);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo borroso
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Image.asset(
            coverPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.25),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        // Contenido principal
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? width * 0.2 : 24,
                vertical: isWide ? 48 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Carátula
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        coverPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  SizedBox(height: isWide ? 40 : 28),
                  // Título
                  Text(
                    songTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 32 : 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isWide ? 18 : 10),
                  // Artista
                  Text(
                    artist,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isWide ? 20 : 15,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isWide ? 36 : 24),
                  // Barra de progreso + corazón
                  Row(
                    children: [
                      // Barra de progreso
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: isWide ? 8 : 5,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0,
                            ),
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: pink.withOpacity(0.85),
                            inactiveTrackColor: Colors.white.withOpacity(0.25),
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: null, // Deshabilitado (mockup)
                          ),
                        ),
                      ),
                      SizedBox(width: isWide ? 18 : 10),
                      // Corazón
                      GestureDetector(
                        onTap: () => setState(() => isLiked = !isLiked),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isWide ? 8 : 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? pink
                                : Colors.white.withOpacity(0.7),
                            size: isWide ? 34 : 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWide ? 36 : 24),
                  // Controles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: Colors.white,
                          size: isWide ? 38 : 28,
                        ),
                        onPressed: () {},
                        splashRadius: isWide ? 28 : 22,
                      ),
                      SizedBox(width: isWide ? 32 : 18),
                      Container(
                        decoration: BoxDecoration(
                          color: pink,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: pink.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: isWide ? 44 : 32,
                          ),
                          onPressed: () {},
                          splashRadius: isWide ? 32 : 24,
                        ),
                      ),
                      SizedBox(width: isWide ? 32 : 18),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: Colors.white,
                          size: isWide ? 38 : 28,
                        ),
                        onPressed: () {},
                        splashRadius: isWide ? 28 : 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
