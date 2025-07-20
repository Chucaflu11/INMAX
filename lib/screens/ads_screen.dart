// ads_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  Map<String, bool> selectedAds = {
    'monster': false,
    'vans': false,
    'converse': false,
    'redbull': false,
    'mcdonalds': false,
    'starbucks': false,
    'adidas': false,
    'kfc': false,
    'cocacola': false,
    'nike': false,
  };

  String? selectedPostUri;
  List<Map<String, dynamic>> userPosts = [];
  bool isLoading = false;
  String? error;

  String? get authToken => AuthService.session?.accessJwt;
  String? get userHandle => AuthService.session?.handle;

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  Future<void> fetchUserPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

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
        final List<Map<String, dynamic>> fetchedPosts = [];

        for (var item in data['feed']) {
          final post = item['post'];
          final embed = post['embed'];
          String imageUrl = '';

          if (embed != null) {
            final type = embed['\$type'];
            if (type == 'app.bsky.embed.images#view') {
              imageUrl = embed['images'][0]['thumb'];
            } else if (type == 'app.bsky.embed.recordWithMedia#view') {
              final media = embed['media'];
              if (media['\$type'] == 'app.bsky.embed.images#view') {
                imageUrl = media['images'][0]['thumb'];
              }
            }
          }

          fetchedPosts.add({
            'uri': post['uri'],
            'text': post['record']['text'] ?? '',
            'image': imageUrl,
          });
        }

        setState(() {
          userPosts = fetchedPosts;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'No se pudieron obtener las publicaciones';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener publicaciones: $e';
        isLoading = false;
      });
    }
  }

  Future<void> saveAdSettings() async {
    if (selectedPostUri == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedPostUri!, jsonEncode(selectedAds));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada localmente.')),
    );
  }

  Future<void> loadAdSettings(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(uri);
    if (jsonString != null) {
      final Map<String, dynamic> saved = jsonDecode(jsonString);
      setState(() {
        selectedAds = {
          for (var key in selectedAds.keys)
            key: saved[key]?.toString() == 'true'
        };
      });
    } else {
      setState(() {
        selectedAds = {
          for (var key in selectedAds.keys) key: false
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Anuncios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona una publicación para configurar sus anuncios:'),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPostUri,
                    hint: const Text('Seleccionar publicación'),
                    items: userPosts.map<DropdownMenuItem<String>>((post) {
                      return DropdownMenuItem<String>(
                        value: post['uri'] as String,
                        child: Row(
                          children: [
                            if (post['image'] != '')
                              Image.network(post['image'], width: 32, height: 32, fit: BoxFit.cover),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                post['text'].isEmpty ? '[Sin texto]' : post['text'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPostUri = val;
                      });
                      loadAdSettings(val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedPostUri != null)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: selectedAds.keys.map((brand) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(brand, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Image.asset(
                                      'assets/ads/$brand.jpg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Permitir'),
                                      Switch(
                                        value: selectedAds[brand]!,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAds[brand] = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (selectedPostUri != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveAdSettings,
                        child: const Text('Guardar configuración'),
                      ),
                    )
                ],
              ),
      ),
    );
  }
}