import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _allowAds = false;
  final List<PlatformFile?> _slides = [null];

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

  final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  bool _isExtensionAllowed(String path) {
    return allowedExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  Future<Map<String, dynamic>> uploadImageToBluesky(File file) async {
    if (!_isExtensionAllowed(file.path)) {
      throw Exception('Tipo de imagen no soportado: ${file.path}');
    }

    final uri = Uri.parse('https://bsky.social/xrpc/com.atproto.repo.uploadBlob');
    final bytes = await file.readAsBytes();

    // Determine MIME type from file extension
    String contentType;
    final extension = file.path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
      default:
        throw Exception('Formato de imagen no soportado: $extension');
    }

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AuthService.session?.accessJwt}',
        'Content-Type': contentType,
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falló la subida de imagen: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> publishReel() async {
    final title = _titleController.text.trim();
    final validSlides = _slides.where((s) => s != null).toList();

    if (title.isEmpty || validSlides.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes ingresar un título y al menos una imagen.')),
      );
      return;
    }

    try {
      final List<Map<String, dynamic>> images = [];
      for (final file in validSlides) {
        final uploaded = await uploadImageToBluesky(File(file!.path!));
        images.add({
          'image': uploaded['blob'],
          'alt': 'Slide image'
        });
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final postBody = {
        'repo': AuthService.session!.did,
        'collection': 'app.bsky.feed.post',
        'record': {
          'text': title,
          'createdAt': now,
          'embed': {
            '\$type': 'app.bsky.embed.images',
            'images': images
          }
        }
      };

      final response = await http.post(
        Uri.parse('https://bsky.social/xrpc/com.atproto.repo.createRecord'),
        headers: {
          'Authorization': 'Bearer ${AuthService.session?.accessJwt}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postBody),
      );

      if (response.statusCode == 200) {
        if (_allowAds) {
          final prefs = await SharedPreferences.getInstance();
          final postUri = jsonDecode(response.body)['uri'];
          await prefs.setString(postUri, jsonEncode(selectedAds));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reel publicado 🎉')),
        );

        setState(() {
          _titleController.clear();
          _allowAds = false;
          _slides.clear();
          _slides.add(null);
          selectedAds = {for (var key in selectedAds.keys) key: false};
        });
      } else {
        throw Exception('Error al publicar: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _pickImage(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (_isExtensionAllowed(file.path!)) {
        setState(() {
          _slides[index] = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formato de imagen no soportado. Usa JPG, PNG o WEBP.')),
        );
      }
    }
  }

  void _addSlide() {
    if (_slides.length < 10) {
      setState(() {
        _slides.add(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Center(
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: isWide ? 0.5 : 0.95,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isWide ? 32 : 20,
                horizontal: isWide ? 32 : 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título del Reel',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isWide ? 20 : 14,
                        horizontal: isWide ? 20 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Allow Advertisements', style: theme.textTheme.bodyLarge),
                      Switch(
                        value: _allowAds,
                        onChanged: (val) => setState(() => _allowAds = val),
                        activeColor: Colors.pinkAccent,
                      ),
                    ],
                  ),
                  if (_allowAds)
                    Column(
                      children: selectedAds.keys.map((brand) {
                        return SwitchListTile(
                          title: Text(brand),
                          value: selectedAds[brand]!,
                          onChanged: (value) {
                            setState(() {
                              selectedAds[brand] = value;
                            });
                          },
                          activeColor: Colors.pinkAccent,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 18),
                  ...List.generate(_slides.length, (i) {
                    final file = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Slide ${i + 1}', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _pickImage(i),
                            child: Container(
                              width: double.infinity,
                              height: isWide ? 180 : 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!, width: 1.2),
                              ),
                              alignment: Alignment.center,
                              child: file == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate, color: Colors.pinkAccent, size: isWide ? 48 : 36),
                                        const SizedBox(height: 8),
                                        Text('Seleccionar imagen', style: TextStyle(color: Colors.grey[600], fontSize: isWide ? 16 : 13)),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.image, color: Colors.green),
                                        const SizedBox(height: 8),
                                        Text(file.name, style: TextStyle(color: Colors.black87, fontSize: isWide ? 15 : 12, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_slides.length < 10)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _addSlide,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: const Text('Add Slide'),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: publishReel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.symmetric(vertical: isWide ? 22 : 16),
                        elevation: 2,
                      ),
                      child: Text(
                        'Create Reel',
                        style: TextStyle(fontSize: isWide ? 20 : 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}