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
  bool isLoading = false;
  String? error;

  String? get authToken => AuthService.session.accessJwt;
  String? get userDid => AuthService.session.did;
  String? get userHandle => AuthService.session.handle;

  @override
  void initState() {
    super.initState();
    fetchProfile();
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

    final int postsCount = profile!['postsCount'] ?? 0;

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
              // Foto de perfil
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

              // Nombre y usuario
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

              // Bio
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

              // Seguidores, seguidos, posts
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStat('Seguidores', '${profile!['followersCount'] ?? 0}',
                      isWide),
                  SizedBox(width: isWide ? 40 : 24),
                  _buildStat(
                      'Seguidos', '${profile!['followsCount'] ?? 0}', isWide),
                  SizedBox(width: isWide ? 40 : 24),
                  _buildStat('Posts', '$postsCount', isWide),
                ],
              ),
              SizedBox(height: isWide ? 32 : 20),

              // Switches
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('Private Profile'),
                    value: isPrivate,
                    activeColor: pink,
                    inactiveThumbColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[200],
                    onChanged: (val) => setState(() => isPrivate = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Public Stage Content'),
                    value: publicStage,
                    activeColor: pink,
                    inactiveThumbColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[200],
                    onChanged: (val) => setState(() => publicStage = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Followers Only'),
                    value: followersOnly,
                    activeColor: pink,
                    inactiveThumbColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[200],
                    onChanged: (val) => setState(() => followersOnly = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),

              // Galería o mensaje
              Divider(height: 32, thickness: 1),
              postsCount == 0
                  ? Column(
                      children: [
                        const SizedBox(height: 24),
                        Icon(Icons.photo_album_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no hay publicaciones',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: postsCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[300],
                          child: Image.network(
                            'https://picsum.photos/seed/post${index + 1}/300',
                            fit: BoxFit.cover,
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
}
