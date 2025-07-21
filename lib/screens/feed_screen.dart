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
  bool isLoadingMore = false;
  bool hasMoreData = true;
  String? cursor;
  late ScrollController _scrollController;

  String? get authToken => AuthService.session?.accessJwt;
  String? get userDid => AuthService.session?.did;
  bool get isAuthenticated => authToken != null && userDid != null;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    fetchWhatsHotFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => isLoadingMore = true);
    try {
      await fetchWhatsHotFeed(loadMore: true);
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1200;
  bool isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1200;
  bool isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  int getCrossAxisCount(BuildContext ctx) {
    if (isDesktop(ctx)) return 4;
    if (isTablet(ctx)) return 3;
    return 2;
  }

  double getChildAspectRatio(BuildContext ctx) {
    if (isDesktop(ctx)) return 0.75;
    if (isTablet(ctx)) return 0.7;
    return 0.65;
  }

  EdgeInsets getResponsivePadding(BuildContext ctx) {
    if (isDesktop(ctx)) return const EdgeInsets.symmetric(horizontal: 24);
    if (isTablet(ctx)) return const EdgeInsets.symmetric(horizontal: 18);
    return const EdgeInsets.symmetric(horizontal: 12);
  }

  double getResponsiveSpacing(BuildContext ctx) {
    if (isDesktop(ctx)) return 8;
    if (isTablet(ctx)) return 7;
    return 6;
  }

  Future<void> fetchWhatsHotFeed({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        posts = [];
        cursor = null;
        hasMoreData = true;
      });
    }

    try {
      final queryParams = {
        'feed':
            'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot',
        'limit': '30',
        if (loadMore && cursor != null) 'cursor': cursor!,
      };

      final response = await http.get(
        Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getFeed')
            .replace(queryParameters: queryParams),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MyFlutterApp/1.0',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await processWhatsHotData(data, loadMore: loadMore);
        setState(() {
          if (!loadMore) isLoading = false;
          if (posts.isEmpty && !loadMore) {
            errorMessage =
                'No se encontraron posts con imágenes en What\'s Hot';
          }
        });
      } else {
        if (!loadMore) await fetchFallbackFeeds();
      }
    } catch (e) {
      if (!loadMore) await fetchFallbackFeeds();
    }
  }

  Future<void> processWhatsHotData(Map<String, dynamic> data,
      {bool loadMore = false}) async {
    if (data['feed'] != null) {
      final List<dynamic> feedPosts = data['feed'];
      cursor = data['cursor'] as String?;
      if (cursor == null || cursor!.isEmpty) hasMoreData = false;

      final extracted = feedPosts.where((item) {
        final post = item['post'];
        final embed = post['embed'];
        if (embed == null) return false;
        final type = embed['\$type'] as String?;
        if (type!.startsWith('app.bsky.embed.images')) {
          return (embed['images'] as List).isNotEmpty;
        } else if (type ==
            'app.bsky.embed.recordWithMedia#view') {
          final media = embed['media'];
          return media != null &&
              media['images'] != null &&
              (media['images'] as List).isNotEmpty;
        }
        return false;
      }).map((item) {
        final post = item['post'];
        post['hasLiked'] = false;
        return item;
      }).toList();

      setState(() {
        if (loadMore) posts.addAll(extracted);
        else posts = extracted;
      });
    }
  }

  Future<void> fetchFallbackFeeds() async {
    try {
      final fallbackFeeds = [
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/bsky-team',
        'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic',
      ];
      for (final feedUri in fallbackFeeds) {
        final response = await http.get(
          Uri.parse('https://bsky.social/xrpc/app.bsky.feed.getFeed')
              .replace(queryParameters: {'feed': feedUri, 'limit': '20'}),
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
      if (posts.isEmpty) await fetchPublicProfiles();
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
    final profiles = ['bsky.app', 'jay.bsky.team', 'atproto.com', 'pfrazee.com'];
    for (final handle in profiles) {
      try {
        final response = await http.get(
          Uri.parse(
              'https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed?actor=$handle&limit=15'),
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
      } catch (_) {}
    }
  }

  String getImageUrl(dynamic embed) {
    try {
      final type = embed['\$type'] as String?;
      if (type!.startsWith('app.bsky.embed.images')) {
        return embed['images'][0]['thumb'] as String? ?? '';
      } else if (type ==
          'app.bsky.embed.recordWithMedia#view') {
        return embed['media']['images'][0]['thumb'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }

  Future<void> _toggleLike(int idx) async {
    final post = posts[idx]['post'];
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para dar like')),
      );
      return;
    }
    final id = post['uri'] ?? post['cid'] ?? idx.toString();
    final liked = post['hasLiked'] as bool;
    setState(() {
      post['hasLiked'] = !liked;
      post['likeCount'] = (post['likeCount'] ?? 0) + (liked ? -1 : 1);
    });

    try {
      final url = liked
          ? 'https://bsky.social/xrpc/app.bsky.like.deleteLike'
          : 'https://bsky.social/xrpc/app.bsky.like.createLike';
      await http.post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({'subject': id}));
    } catch (_) {
      // Optionally revert on error
    }
  }

  Widget _buildCard(dynamic post) {
    final embed = post['post']['embed'];
    final imageUrl = getImageUrl(embed);
    final author = post['post']['author'];
    final title = author['displayName'] ??
        author['handle']?.split('.')[0] ??
        'Usuario';
    final handleString = author['handle']
        ?.replaceAll('.bsky.social', '') ??
        'usuario';
    final likeCount = (post['post']['likeCount'] ?? 0).toString();
    final hasLiked = post['post']['hasLiked'] as bool;

    return GestureDetector(
      onTap: () => _toggleLike(posts.indexOf(post)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(color: Colors.grey[300]),
            ),
          ),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: isMobile(context) ? 1 : 2,
              overflow: TextOverflow.ellipsis),
          Text('@$handleString',
              style: TextStyle(color: Colors.grey, fontSize: isDesktop(context) ? 12 : 10)),
          const SizedBox(height: 2),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  hasLiked ? Icons.favorite : Icons.favorite_border,
                  color: hasLiked ? Colors.red : null,
                ),
                onPressed: () => _toggleLike(posts.indexOf(post)),
              ),
              Text(likeCount,
                  style: TextStyle(fontSize: isDesktop(context) ? 14 : 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: getResponsivePadding(context),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Cargando What\'s Hot desde Bluesky...',
              style: TextStyle(fontSize: isDesktop(context) ? 16 : 14)),
          const SizedBox(height: 8),
          Text(
            isAuthenticated
                ? 'Usuario autenticado'
                : 'Sin autenticar - usando feed público',
            style: TextStyle(
                fontSize: isDesktop(context) ? 14 : 12,
                color: isAuthenticated ? Colors.grey : Colors.orange),
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
            Row(children: [
              Icon(Icons.info,
                  color: Colors.orange, size: isDesktop(context) ? 24 : 20),
              const SizedBox(width: 8),
              Text('Información:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: isDesktop(context) ? 16 : 14)),
            ]),
            const SizedBox(height: 8),
            Text(errorMessage ?? '',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: isDesktop(context) ? 14 : 12)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadMorePosts,
              icon: const Icon(Icons.play_circle, size: 16),
              label: const Text('Ver contenido demo'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
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
            Icon(Icons.image_not_supported,
                size: isDesktop(context)
                    ? 80
                    : isTablet(context)
                        ? 72
                        : 64,
                color: Colors.grey),
            const SizedBox(height: 16),
            Text('No hay posts disponibles en What\'s Hot',
                style: TextStyle(
                    fontSize: isDesktop(context)
                        ? 18
                        : isTablet(context)
                            ? 16
                            : 14),
                textAlign: TextAlign.center),
            if (!isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Inicia sesión para acceder a más contenido',
                    style: TextStyle(
                        fontSize: isDesktop(context) ? 14 : 12,
                        color: Colors.grey),
                    textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(height: 8),
        const Text('Cargando más...', style: TextStyle(fontSize: 12)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (isLoading) _buildLoadingWidget(),
      if (errorMessage != null && !isLoading) _buildErrorWidget(),
      Expanded(
          child: posts.isEmpty && !isLoading
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => fetchWhatsHotFeed(),
                  child: Padding(
                    padding: getResponsivePadding(context),
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(context),
                        crossAxisSpacing: getResponsiveSpacing(context),
                        mainAxisSpacing: getResponsiveSpacing(context),
                        childAspectRatio: getChildAspectRatio(context),
                      ),
                      itemCount:
                          posts.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (ctx, idx) {
                        if (idx == posts.length && isLoadingMore) {
                          return _buildLoadMoreIndicator();
                        }
                        return _buildCard(posts[idx]);
                      },
                    ),
                  ),
                ))
    ]);
  }
}
