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
        .replace(
          queryParameters: {
            userDid != null ? 'actor' : 'handle': userDid ?? userHandle ?? '',
          },
        );

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

    return SingleChildScrollView(
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
                Column(
                  children: [
                    Text(
                      '${profile!['followersCount'] ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 16,
                      ),
                    ),
                    Text(
                      'Seguidores',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 15 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isWide ? 40 : 24),
                Column(
                  children: [
                    Text(
                      '${profile!['followsCount'] ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 16,
                      ),
                    ),
                    Text(
                      'Seguidos',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 15 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isWide ? 40 : 24),
                Column(
                  children: [
                    Text(
                      '${profile!['postsCount'] ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 16,
                      ),
                    ),
                    Text(
                      'Posts',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 15 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isWide ? 32 : 20),
            // Toggles
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
          ],
        ),
      ),
    );
  }
}
