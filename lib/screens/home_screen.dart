import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  String? errorMessage;
  bool isLoading = false;

  // Obtener credenciales del AuthService
  String? get authToken => AuthService.session.accessJwt;
  String? get userDid => AuthService.session.did;
  bool get isAuthenticated => authToken != null && userDid != null;

  @override
  void initState() {
    super.initState();
    fetchWhatsHotFeed();
  }

  Future<void> fetchWhatsHotFeed() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      posts = [];
    });

    try {
      // Usar el endpoint What's Hot directamente
      final response = await http.get(
        Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getFeed')
            .replace(queryParameters: {
          'feed': 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot',
          'limit': '30',
        }),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('What\'s Hot Feed Status: ${response.statusCode}');
      print('Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await processWhatsHotData(data);

        setState(() {
          isLoading = false;
          if (posts.isEmpty) {
            errorMessage = 'No se encontraron posts con imágenes en What\'s Hot';
          }
        });
      } else {
        print('Error response: ${response.body}');
        // Fallback a feeds públicos si falla What's Hot
        await fetchFallbackFeeds();
      }

    } catch (e) {
      print('Error en fetchWhatsHotFeed: $e');
      await fetchFallbackFeeds();
    }
  }

  Future<void> processWhatsHotData(Map<String, dynamic> data) async {
    if (data['feed'] != null) {
      final List<dynamic> feedPosts = data['feed'];
      print('Total posts received: ${feedPosts.length}');

      // Filtrar posts que tengan imágenes
      final postsWithImages = feedPosts.where((feedItem) {
        final post = feedItem['post'];
        final embed = post['embed'];

        if (embed == null) return false;

        // Verificar diferentes tipos de embeds que pueden contener imágenes
        bool hasImages = false;
        final String? embedType = embed['\$type'] as String?;

        if (embedType == 'app.bsky.embed.images#view' ||
            embedType == 'app.bsky.embed.images') {
          hasImages = embed['images'] != null && (embed['images'] as List).isNotEmpty;
        } else if (embedType == 'app.bsky.embed.recordWithMedia#view') {
          if (embed['media'] != null) {
            final media = embed['media'];
            final mediaType = media['\$type'] as String?;
            if (mediaType == 'app.bsky.embed.images#view') {
              hasImages = media['images'] != null && (media['images'] as List).isNotEmpty;
            }
          }
        }

        if (hasImages) {
          print('Found post with images: ${post['author']?['handle']} - ${post['record']?['text']?.toString().substring(0, 50)}...');
        }

        return hasImages;
      }).toList();

      print('Posts with images: ${postsWithImages.length}');

      if (postsWithImages.isNotEmpty) {
        setState(() {
          posts.addAll(postsWithImages);
        });
      }
    }
  }

  Future<void> fetchFallbackFeeds() async {
    try {
      // Intentar otros feeds populares como fallback
      final fallbackFeeds = [
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/bsky-team',
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic',
      ];

      for (String feedUri in fallbackFeeds) {
        final response = await http.get(
          Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getFeed')
              .replace(queryParameters: {
            'feed': feedUri,
            'limit': '20',
          }),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'MyFlutterApp/1.0',
            if (isAuthenticated) 'Authorization': 'Bearer $authToken',
          },
        );

        print('Fallback Feed Status: ${response.statusCode} for $feedUri');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await processWhatsHotData(data);
          if (posts.isNotEmpty) break;
        }
      }

      // Si aún no hay posts, cargar perfiles públicos conocidos
      if (posts.isEmpty) {
        await fetchPublicProfiles();
      }

      setState(() {
        isLoading = false;
        if (posts.isEmpty) {
          errorMessage = 'No se pudieron cargar posts con imágenes desde ningún feed';
        }
      });

    } catch (e) {
      print('Error en fetchFallbackFeeds: $e');
      setState(() {
        errorMessage = 'Error al cargar contenido: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchPublicProfiles() async {
    // Perfiles públicos conocidos que suelen tener contenido visual
    final List<String> publicProfiles = [
      'bsky.app',
      'jay.bsky.team',
      'atproto.com',
      'pfrazee.com',
    ];

    for (String handle in publicProfiles) {
      try {
        final response = await http.get(
          Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed?actor=$handle&limit=15'),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'MyFlutterApp/1.0',
          },
        );

        print('Public Profile Status: ${response.statusCode} for $handle');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await processWhatsHotData(data);
          if (posts.length >= 10) break;
        }
      } catch (e) {
        print('Error fetching profile $handle: $e');
        continue;
      }
    }
  }

  String getImageUrl(dynamic embed) {
    try {
      final String? embedType = embed['\$type'] as String?;

      // Para embeds de imágenes directas (vista)
      if (embedType == 'app.bsky.embed.images#view') {
        if (embed['images'] != null && embed['images'].isNotEmpty) {
          return embed['images'][0]['thumb'] as String? ?? '';
        }
      }
      // Para embeds compuestos (vista)
      else if (embedType == 'app.bsky.embed.recordWithMedia#view') {
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
    } catch (e) {
      print('Error obteniendo URL de imagen: $e');
    }
    return '';
  }

  // Método para obtener posts de demostración si todo falla
  void loadDemoPosts() {
    setState(() {
      posts = [
        {
          'post': {
            'author': {
              'displayName': 'Demo User 1',
              'handle': 'demo1.bsky.social',
            },
            'record': {'text': 'Este es un post de demostración con imagen'},
            'likeCount': 42,
            'embed': {
              '\$type': 'app.bsky.embed.images',
              'images': [
                {
                  'image': {
                    'ref': {'\$link': 'demo-image-1'},
                  },
                },
              ],
            },
          },
        },
        {
          'post': {
            'author': {
              'displayName': 'Demo User 2',
              'handle': 'demo2.bsky.social',
            },
            'record': {'text': 'Otro post de demostración'},
            'likeCount': 24,
            'embed': {
              '\$type': 'app.bsky.embed.images',
              'images': [
                {
                  'image': {
                    'ref': {'\$link': 'demo-image-2'},
                  },
                },
              ],
            },
          },
        },
      ];
      isLoading = false;
      errorMessage = 'Mostrando contenido de demostración - What\'s Hot no disponible';
    });
  }

  Widget _buildCard(String imageUrl, String title, String likes, String handle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty && imageUrl.startsWith('https')
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  print('Error cargando imagen: $imageUrl - $error');
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 50),
                          SizedBox(height: 8),
                          Text(
                            'Imagen no disponible',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.blue[100],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Imagen demo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Flexible(
            child: Text(
              '@$handle',
              style: const TextStyle(color: Colors.black54, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.favorite_border,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                likes,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBar() {
    return Container(
      color: const Color(0xFFFF385D),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.pause, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Song Name", style: TextStyle(color: Colors.white)),
                Text(
                  "Artist Name",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.favorite_border, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: const Color(0xFFFF385D),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icons/inmaxpng.png', height: 50),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchWhatsHotFeed,
              tooltip: 'Recargar What\'s Hot',
            ),
            IconButton(
              icon: const Icon(Icons.play_circle),
              onPressed: loadDemoPosts,
              tooltip: 'Cargar contenido demo',
            ),
            const Icon(Icons.search),
            const SizedBox(width: 16),
            const Icon(Icons.menu),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Cargando What\'s Hot desde Bluesky...'),
                  if (isAuthenticated)
                    Text(
                      'Usuario autenticado: ${userDid?.split(':').last.substring(0, 8)}...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else
                    Text(
                      'Sin autenticar - usando feed público',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                ],
              ),
            ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Información:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: loadDemoPosts,
                      icon: const Icon(Icons.play_circle, size: 16),
                      label: const Text('Ver contenido demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: posts.isEmpty && !isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No hay posts disponibles en What\'s Hot'),
                  const SizedBox(height: 8),
                  if (!isAuthenticated)
                    const Text(
                      'Inicia sesión para acceder a más contenido',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: loadDemoPosts,
                    icon: const Icon(Icons.play_circle),
                    label: const Text('Ver contenido demo'),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index]['post'];
                  final author = post['author'];
                  final embed = post['embed'];

                  final imageUrl = getImageUrl(embed);
                  final title = author['displayName'] ??
                      author['handle']?.split('.')[0] ??
                      'Usuario';
                  final handle = author['handle']?.replaceAll('.bsky.social', '') ?? 'usuario';
                  final likes = post['likeCount']?.toString() ?? '0';

                  return _buildCard(imageUrl, title, likes, handle);
                },
              ),
            ),
          ),
          _buildPlayerBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}