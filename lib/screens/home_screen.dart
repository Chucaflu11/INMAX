import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  String? errorMessage;
  bool isLoading = false;

  // DIDs de perfiles públicos conocidos con contenido visual
  final List<String> profileDids = [
    'did:plc:xo32sqgvpykv4vp65l3jnupd', // effinbirds.com
    'did:plc:z72i7hdynmk6r22z27h6tvur', // bsky.app (oficial)
    'did:plc:oky5czdrnfjpqslsw2a5iclo', // jay.bsky.team
  ];

  @override
  void initState() {
    super.initState();
    fetchPostsWithImages();
  }

  Future<void> fetchPostsWithImages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      posts = [];
    });

    try {
      // Método 1: Obtener posts de perfiles específicos conocidos por tener imágenes
      for (String did in profileDids) {
        await fetchAuthorFeed(did);
        if (posts.isNotEmpty) break; // Si encontramos posts, paramos
      }

      // Si no encontramos posts, intentar método alternativo
      if (posts.isEmpty) {
        await fetchPopularPosts();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error general: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAuthorFeed(String authorDid) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=$authorDid&limit=50',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
        },
      );

      print('Author Feed Status: ${response.statusCode}');
      print(
        'Author Feed Response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['feed'] != null) {
          // Filtrar solo posts que tengan imágenes
          final postsWithImages = (data['feed'] as List).where((post) {
            final embed = post['post']['embed'];
            return embed != null &&
                embed['images'] != null &&
                (embed['images'] as List).isNotEmpty;
          }).toList();

          if (postsWithImages.isNotEmpty) {
            setState(() {
              posts.addAll(postsWithImages);
            });
          }
        }
      } else if (response.statusCode != 404) {
        print(
          'Error en author feed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error en fetchAuthorFeed: $e');
    }
  }

  Future<void> fetchPopularPosts() async {
    try {
      // Usar el endpoint de posts populares/trending (si está disponible)
      final response = await http.get(
        Uri.parse(
          'https://public.api.bsky.app/xrpc/app.bsky.unspecced.getPopular?limit=50',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
        },
      );

      print('Popular Posts Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['feed'] != null) {
          // Filtrar posts con imágenes
          final postsWithImages = (data['feed'] as List).where((post) {
            final embed = post['post']['embed'];
            return embed != null &&
                embed['images'] != null &&
                (embed['images'] as List).isNotEmpty;
          }).toList();

          setState(() {
            posts.addAll(postsWithImages);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Si popular no funciona, intentar método de resolución de handle
        await fetchByHandleResolution();
      }
    } catch (e) {
      print('Error en fetchPopularPosts: $e');
      await fetchByHandleResolution();
    }
  }

  Future<void> fetchByHandleResolution() async {
    try {
      // Resolver el handle a DID primero
      final resolveResponse = await http.get(
        Uri.parse(
          'https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=effinbirds.com&limit=20',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
        },
      );

      print('Resolve Handle Status: ${resolveResponse.statusCode}');
      print('Resolve Handle Response: ${resolveResponse.body}');

      if (resolveResponse.statusCode == 200) {
        final resolveData = json.decode(resolveResponse.body);
        final did = resolveData['did'];

        if (did != null) {
          await fetchAuthorFeed(did);
        }
      }

      setState(() {
        isLoading = false;
        if (posts.isEmpty) {
          errorMessage =
              'No se pudieron cargar posts con imágenes. Esto puede deberse a limitaciones de la API pública.';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error final: $e';
        isLoading = false;
      });
    }
  }

  // Método para cargar posts de demostración si la API falla
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
      errorMessage =
          'Mostrando contenido de demostración debido a limitaciones de API pública';
    });
  }

  Widget _buildCard(String imageUrl, String title, String likes, String text) {
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
              child: imageUrl.startsWith('https')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
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
          if (text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
              onPressed: fetchPostsWithImages,
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Cargando posts con imágenes...'),
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
                        const Text('No hay posts disponibles'),
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
                        final post = posts[index];
                        final record = post['post']['record'];
                        final embed = record['embed'];
                        final images = embed?['images'] ?? [];

                        final imageUrl = images.isNotEmpty
                            ? 'https://cdn.bsky.app/img/feed_thumbnail/plain/${images[0]['image']['ref']['\$link']}@jpeg'
                            : 'demo';

                        final title =
                            post['post']['author']['displayName'] ??
                            post['post']['author']['handle'] ??
                            'Usuario';
                        final likes =
                            post['post']['likeCount']?.toString() ?? '0';
                        final text = record['text'] ?? '';

                        return _buildCard(imageUrl, title, likes, text);
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
