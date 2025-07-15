import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPrivate = false;
  bool publicStage = true;
  bool followersOnly = false;

  Map<String, dynamic>? profile;
  List<dynamic> posts = [];
  bool isLoading = false;
  String? error;

  String? get authToken => AuthService.session?.accessJwt;
  String? get userDid => AuthService.session?.did;
  String? get userHandle => AuthService.session?.handle;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchUserPosts();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final uri = Uri.parse('https://bsky.social/xrpc/app.bsky.actor.getProfile')
        .replace(queryParameters: {
      userDid != null ? 'actor' : 'handle': userDid ?? userHandle ?? '',
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          profile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'No se pudo cargar el perfil';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserPosts() async {
    final uri = Uri.parse(
      'https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed?actor=$userHandle&limit=20',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['feed'];
        });
      }
    } catch (e) {
      print('Error al obtener publicaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;
    final pink = const Color(0xFFFF385D);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (profile == null) {
      return const Center(child: Text('Perfil no disponible'));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? width * 0.18 : 20,
            vertical: isWide ? 36 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: isWide ? 60 : 48,
                backgroundImage: profile!['avatar'] != null
                    ? NetworkImage(profile!['avatar'])
                    : null,
                child: profile!['avatar'] == null
                    ? Icon(Icons.person, size: isWide ? 60 : 48)
                    : null,
              ),
              SizedBox(height: isWide ? 24 : 16),
              Text(
                profile!['displayName'] ?? '',
                style: TextStyle(
                  fontSize: isWide ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '@${profile!['handle'] ?? ''}',
                style: TextStyle(
                  fontSize: isWide ? 18 : 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isWide ? 18 : 12),
              if (profile!['description'] != null)
                Text(
                  profile!['description'],
                  style: TextStyle(
                    fontSize: isWide ? 17 : 13,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: isWide ? 24 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStat('Seguidores', '${profile!['followersCount'] ?? 0}', isWide),
                  SizedBox(width: isWide ? 40 : 24),
                  _buildStat('Seguidos', '${profile!['followsCount'] ?? 0}', isWide),
                  SizedBox(width: isWide ? 40 : 24),
                  _buildStat('Posts', '${posts.length}', isWide),
                ],
              ),
              SizedBox(height: isWide ? 32 : 20),
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Private Profile'),
                    value: isPrivate,
                    activeColor: pink,
                    onChanged: (val) => setState(() => isPrivate = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Public Stage Content'),
                    value: publicStage,
                    activeColor: pink,
                    onChanged: (val) => setState(() => publicStage = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Followers Only'),
                    value: followersOnly,
                    activeColor: pink,
                    onChanged: (val) => setState(() => followersOnly = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              Divider(height: 32, thickness: 1),
              posts.isEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 24),
                        Icon(Icons.photo_album_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('Aún no hay publicaciones', style: TextStyle(color: Colors.grey[600])),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final post = posts[index]['post'];
                        final embed = post['embed'];
                        final imageUrl = getImageUrl(embed);

                        return GestureDetector(
                          onTap: () => showPostDetails(context, post),
                          child: Container(
                            color: Colors.grey[300],
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String count, bool isWide) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isWide ? 20 : 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isWide ? 15 : 12,
          ),
        ),
      ],
    );
  }

  String getImageUrl(dynamic embed) {
    try {
      final type = embed['\$type'];
      if (type == 'app.bsky.embed.images#view') {
        return embed['images'][0]['thumb'];
      } else if (type == 'app.bsky.embed.recordWithMedia#view') {
        final media = embed['media'];
        if (media['\$type'] == 'app.bsky.embed.images#view') {
          return media['images'][0]['thumb'];
        }
      }
    } catch (_) {}
    return '';
  }

  String formatTimeAgo(String dateStr) {
    final postDate = DateTime.parse(dateStr).toLocal();
    final now = DateTime.now();
    final diff = now.difference(postDate);

    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${postDate.day}/${postDate.month}/${postDate.year}';
  }

  void showPostDetails(BuildContext context, dynamic post) {
  final embed = post['embed'];
  final imageUrl = getImageUrl(embed);
  final text = post['record']['text'] ?? '';
  final likes = post['likeCount']?.toString() ?? '0';
  final date = post['record']['createdAt'] ?? '';

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 18, color: Colors.pink),
                      const SizedBox(width: 6),
                      Text('$likes likes', style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      Text(formatTimeAgo(date),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

}
