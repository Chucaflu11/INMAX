import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> posts = [];
  String? errorMessage;
  bool isLoading = false;

  String? get authToken => AuthService.session.accessJwt;
  String? get userDid => AuthService.session.did;
  bool get isAuthenticated => authToken != null && userDid != null;

  @override
  void initState() {
    super.initState();
    fetchWhatsHotFeed();
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  int getCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  double getChildAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 0.75;
    } else if (isTablet(context)) {
      return 0.7;
    } else {
      return 0.65;
    }
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 18);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12);
    }
  }

  double getResponsiveSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return 8;
    } else if (isTablet(context)) {
      return 7;
    } else {
      return 6;
    }
  }

  Future<void> fetchWhatsHotFeed() async {
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
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await processWhatsHotData(data);

        setState(() {
          isLoading = false;
          if (posts.isEmpty) {
            errorMessage =
                'No se encontraron posts con imágenes en What\'s Hot';
          }
        });
      } else {
        await fetchFallbackFeeds();
      }
    } catch (e) {
      await fetchFallbackFeeds();
    }
  }

  Future<void> processWhatsHotData(Map<String, dynamic> data) async {
    if (data['feed'] != null) {
      final List<dynamic> feedPosts = data['feed'];

      final postsWithImages = feedPosts.where((feedItem) {
        final post = feedItem['post'];
        final embed = post['embed'];

        if (embed == null) return false;

        bool hasImages = false;
        final String? embedType = embed['\$type'] as String?;

        if (embedType == 'app.bsky.embed.images#view' ||
            embedType == 'app.bsky.embed.images') {
          hasImages =
              embed['images'] != null && (embed['images'] as List).isNotEmpty;
        } else if (embedType == 'app.bsky.embed.recordWithMedia#view') {
          if (embed['media'] != null) {
            final media = embed['media'];
            final mediaType = media['\$type'] as String?;
            if (mediaType == 'app.bsky.embed.images#view') {
              hasImages =
                  media['images'] != null &&
                  (media['images'] as List).isNotEmpty;
            }
          }
        }
        return hasImages;
      }).toList();

      if (postsWithImages.isNotEmpty) {
        setState(() {
          posts.addAll(postsWithImages);
        });
      }
    }
  }

  Future<void> fetchFallbackFeeds() async {
    try {
      final fallbackFeeds = [
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/bsky-team',
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic',
      ];

      for (String feedUri in fallbackFeeds) {
        final response = await http.get(
          Uri.parse(
            'https://bsky.social/xrpc/app.bsky.feed.getFeed',
          ).replace(queryParameters: {'feed': feedUri, 'limit': '20'}),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'MyFlutterApp/1.0',
            if (isAuthenticated) 'Authorization': 'Bearer $authToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await processWhatsHotData(data);
          if (posts.isNotEmpty) break;
        }
      }

      if (posts.isEmpty) {
        await fetchPublicProfiles();
      }

      setState(() {
        isLoading = false;
        if (posts.isEmpty) {
          errorMessage =
              'No se pudieron cargar posts con imágenes desde ningún feed';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar contenido: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchPublicProfiles() async {
    final List<String> publicProfiles = [
      'bsky.app',
      'jay.bsky.team',
      'atproto.com',
      'pfrazee.com',
    ];

    for (String handle in publicProfiles) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed?actor=$handle&limit=15',
          ),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'MyFlutterApp/1.0',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await processWhatsHotData(data);
          if (posts.length >= 10) break;
        }
      } catch (e) {
        continue;
      }
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
      errorMessage =
          'Mostrando contenido de demostración - What\'s Hot no disponible';
    });
  }

  Widget _buildCard(
    String imageUrl,
    String title,
    String likes,
    String handle,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth;

        final titleFontSize = isDesktop(context)
            ? 16.0
            : isTablet(context)
            ? 15.0
            : 14.0;
        final handleFontSize = isDesktop(context)
            ? 12.0
            : isTablet(context)
            ? 11.0
            : 10.0;
        final likesFontSize = isDesktop(context)
            ? 14.0
            : isTablet(context)
            ? 13.0
            : 12.0;
        final iconSize = isDesktop(context)
            ? 18.0
            : isTablet(context)
            ? 16.0
            : 14.0;

        return Container(
          margin: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: imageHeight,
                width: double.infinity,
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
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: iconSize * 2.5,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Imagen no disponible',
                                      style: TextStyle(
                                        fontSize: handleFontSize,
                                      ),
                                      textAlign: TextAlign.center,
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: iconSize * 2.5,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagen demo',
                                  style: TextStyle(fontSize: handleFontSize),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
                maxLines: isMobile(context) ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                '@$handle',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: handleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: iconSize,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likes,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: likesFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: getResponsivePadding(context),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando What\'s Hot desde Bluesky...',
            style: TextStyle(fontSize: isDesktop(context) ? 16 : 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (isAuthenticated)
            Text(
              'Usuario autenticado: ${userDid?.split(':').last.substring(0, 8)}...',
              style: TextStyle(
                fontSize: isDesktop(context) ? 14 : 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Sin autenticar - usando feed público',
              style: TextStyle(
                fontSize: isDesktop(context) ? 14 : 12,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: getResponsivePadding(context),
      child: Container(
        padding: EdgeInsets.all(isDesktop(context) ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.orange,
                  size: isDesktop(context) ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: isDesktop(context) ? 16 : 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.orange,
                fontSize: isDesktop(context) ? 14 : 12,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loadDemoPosts,
              icon: const Icon(Icons.play_circle, size: 16),
              label: const Text('Ver contenido demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop(context) ? 16 : 12,
                  vertical: isDesktop(context) ? 10 : 6,
                ),
                textStyle: TextStyle(fontSize: isDesktop(context) ? 14 : 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: isDesktop(context)
                  ? 80
                  : isTablet(context)
                  ? 72
                  : 64,
              color: Colors.grey,
            ),
            SizedBox(height: isDesktop(context) ? 24 : 16),
            Text(
              'No hay posts disponibles en What\'s Hot',
              style: TextStyle(
                fontSize: isDesktop(context)
                    ? 18
                    : isTablet(context)
                    ? 16
                    : 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (!isAuthenticated)
              Text(
                'Inicia sesión para acceder a más contenido',
                style: TextStyle(
                  fontSize: isDesktop(context) ? 14 : 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: isDesktop(context) ? 24 : 16),
            ElevatedButton.icon(
              onPressed: loadDemoPosts,
              icon: Icon(Icons.play_circle, size: isDesktop(context) ? 24 : 20),
              label: Text(
                'Ver contenido demo',
                style: TextStyle(fontSize: isDesktop(context) ? 16 : 14),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop(context) ? 24 : 16,
                  vertical: isDesktop(context) ? 12 : 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading) _buildLoadingWidget(),
        if (errorMessage != null && !isLoading) _buildErrorWidget(),
        Expanded(
          child: posts.isEmpty && !isLoading
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchWhatsHotFeed,
                  child: Padding(
                    padding: getResponsivePadding(context),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(context),
                        crossAxisSpacing: getResponsiveSpacing(context),
                        mainAxisSpacing: getResponsiveSpacing(context),
                        childAspectRatio: getChildAspectRatio(context),
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index]['post'];
                        final author = post['author'];
                        final embed = post['embed'];

                        final imageUrl = getImageUrl(embed);
                        final title =
                            author['displayName'] ??
                            author['handle']?.split('.')[0] ??
                            'Usuario';
                        final handle =
                            author['handle']?.replaceAll('.bsky.social', '') ??
                            'usuario';
                        final likes = post['likeCount']?.toString() ?? '0';

                        return _buildCard(imageUrl, title, likes, handle);
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
