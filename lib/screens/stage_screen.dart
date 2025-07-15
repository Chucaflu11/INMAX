import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class StageScreen extends StatefulWidget {
  const StageScreen({super.key});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  List<dynamic> posts = [];
  bool isLoading = false;
  String? errorMessage;
  int currentIndex = 0;

  String? get authToken => AuthService.session?.accessJwt;
  bool get isAuthenticated => authToken != null;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      posts = [];
    });

    try {
      final response = await http.get(
        Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getFeed').replace(
          queryParameters: {
            'feed':
                'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot',
            'limit': '30',
          },
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
          if (isAuthenticated) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        processData(data);
      } else {
        setState(() {
          errorMessage = 'No se pudo cargar el carrusel de imágenes.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar imágenes: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void processData(Map<String, dynamic> data) {
    if (data['feed'] != null) {
      final List<dynamic> feedPosts = data['feed'];
      final postsWithImages = feedPosts.where((feedItem) {
        final post = feedItem['post'];
        final embed = post['embed'];
        if (embed == null) return false;
        final String? embedType = embed['\$type'] as String?;
        if (embedType == 'app.bsky.embed.images#view' ||
            embedType == 'app.bsky.embed.images') {
          return embed['images'] != null &&
              (embed['images'] as List).isNotEmpty;
        } else if (embedType == 'app.bsky.embed.recordWithMedia#view') {
          if (embed['media'] != null) {
            final media = embed['media'];
            final mediaType = media['\$type'] as String?;
            if (mediaType == 'app.bsky.embed.images#view') {
              return media['images'] != null &&
                  (media['images'] as List).isNotEmpty;
            }
          }
        }
        return false;
      }).toList();

      setState(() {
        posts = postsWithImages;
      });
    }
  }

  String getImageUrl(dynamic embed) {
    try {
      final String? embedType = embed['\$type'] as String?;
      if (embedType == 'app.bsky.embed.images#view') {
        if (embed['images'] != null && embed['images'].isNotEmpty) {
          return embed['images'][0]['thumb'] as String? ?? '';
        }
      } else if (embedType == 'app.bsky.embed.recordWithMedia#view') {
        if (embed['media'] != null) {
          final media = embed['media'];
          final mediaType = media['\$type'] as String?;
          if (mediaType == 'app.bsky.embed.images#view') {
            if (media['images'] != null && media['images'].isNotEmpty) {
              return media['images'][0]['thumb'] as String? ?? '';
            }
          }
        }
      }
    } catch (e) {}
    return '';
  }

  int getLikes(dynamic post) {
    return post['likeCount'] is int ? post['likeCount'] : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No hay imágenes para mostrar.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return PageView.builder(
      itemCount: posts.length,
      onPageChanged: (i) => setState(() => currentIndex = i),
      itemBuilder: (context, index) {
        final post = posts[index]['post'];
        final embed = post['embed'];
        final imageUrl = getImageUrl(embed);
        final likes = getLikes(post);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Imagen principal
            imageUrl.isNotEmpty && imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 80)),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  ),
            // Likes en la esquina superior derecha
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.pinkAccent, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '$likes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Indicador de página (opcional, abajo)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  posts.length,
                  (dot) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentIndex == dot ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentIndex == dot
                          ? Colors.pinkAccent
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
