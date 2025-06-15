import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _allowAds = false;
  final List<PlatformFile?> _slides = [null];

  void _pickImage(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _slides[index] = result.files.first;
      });
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
                  // Título
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
                  SizedBox(height: isWide ? 28 : 18),
                  // Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Allow Advertisements',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Switch(
                        value: _allowAds,
                        onChanged: (val) => setState(() => _allowAds = val),
                        activeColor: Colors.pinkAccent,
                        inactiveThumbColor: Colors.grey[300],
                        inactiveTrackColor: Colors.grey[200],
                      ),
                    ],
                  ),
                  SizedBox(height: isWide ? 28 : 18),
                  // Slides
                  ...List.generate(_slides.length, (i) {
                    final file = _slides[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: isWide ? 20 : 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Slide ${i + 1}',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: isWide ? 10 : 6),
                          GestureDetector(
                            onTap: () => _pickImage(i),
                            child: Container(
                              width: double.infinity,
                              height: isWide ? 180 : 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: file == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            color: Colors.pinkAccent, size: isWide ? 48 : 36),
                                        SizedBox(height: 8),
                                        Text(
                                          'Seleccionar imagen',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: isWide ? 16 : 13,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image, color: Colors.green, size: isWide ? 44 : 32),
                                        SizedBox(height: 8),
                                        Text(
                                          file.name,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: isWide ? 15 : 12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Add Slide
                  if (_slides.length < 10)
                    Padding(
                      padding: EdgeInsets.only(bottom: isWide ? 28 : 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _addSlide,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Colors.grey[400]!),
                            padding: EdgeInsets.symmetric(
                              vertical: isWide ? 18 : 12,
                            ),
                          ),
                          child: Text(
                            'Add Slide',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: isWide ? 17 : 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Create Reel
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isWide ? 22 : 16,
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Create Reel',
                        style: TextStyle(
                          fontSize: isWide ? 20 : 16,
                          fontWeight: FontWeight.bold,
                        ),
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