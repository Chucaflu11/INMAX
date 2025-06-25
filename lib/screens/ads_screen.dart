import 'package:flutter/material.dart';
import '../models/ad_model.dart';


import 'package:file_picker/file_picker.dart';
import 'dart:io';


class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Ads')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: AdsContent(),
      ),
    );
  }
}

class AdsContent extends StatefulWidget {
  const AdsContent({super.key});

  @override
  State<AdsContent> createState() => _AdsContentState();
}

class _AdsContentState extends State<AdsContent> {
  final List<AdModel> _ads = [
    AdModel(title: 'ExampleAd', imageUrl: '../assets/taxmanMockup.png', status: 'Active', impressions: 270),
    AdModel(title: 'ExampleAd2', imageUrl: '../assets/taxmanMockup.png', status: 'Active', impressions: 263)
  ];

  @override
  Widget build(BuildContext context) {
    final int totalAds = _ads.length;
    final int totalImpressions = _ads.fold(0, (sum, ad) => sum + ad.impressions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(totalAds, totalImpressions),
        const SizedBox(height: 16),
        const Text("Your Ads", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Create Ad"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => CreateAdModal(
                  onAdCreated: (ad) {
                    setState(() {
                      _ads.add(ad);
                    });
                  },
                ),
              );
            },
          ),
        ),
        const Text("Manage your ad content and track performance."),
        const SizedBox(height: 16),
        Expanded(child: _buildAdList()),
      ],
    );
  }

  Widget _buildSummary(int ads, int impressions) {
    return Row(
      children: [
        _buildStatCard("Total Ads", ads.toString()),
        const SizedBox(width: 16),
        _buildStatCard("Total Impressions", impressions.toString()),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

Widget _buildAdList() {
  return ListView.builder(
    itemCount: _ads.length,
    itemBuilder: (context, index) {
      final ad = _ads[index];

      Widget leadingImage;

      if (Uri.tryParse(ad.imageUrl)?.hasAbsolutePath == true &&
          (ad.imageUrl.endsWith('.jpg') ||
              ad.imageUrl.endsWith('.jpeg') ||
              ad.imageUrl.endsWith('.png') ||
              ad.imageUrl.endsWith('.webp'))) {
        leadingImage = Image.network(
          ad.imageUrl,
          width: 50,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/placeholder.jpg',
                width: 50, height: 70, fit: BoxFit.cover);
          },
        );
      } else if (File(ad.imageUrl).existsSync()) {
        leadingImage = Image.file(File(ad.imageUrl),
            width: 50, height: 70, fit: BoxFit.cover);
      } else {
        leadingImage = Image.asset('assets/placeholder.jpg',
            width: 50, height: 70, fit: BoxFit.cover);
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: leadingImage,
          title: Text(ad.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: ${ad.status}"),
              Text("Impressions: ${ad.impressions}"),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.pause), onPressed: () {/* TODO: toggle */}),
              IconButton(icon: const Icon(Icons.edit), onPressed: () {/* TODO: edit */}),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Ad"),
                      content: const Text("Are you sure you want to delete this ad?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _ads.removeAt(index);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
}


class CreateAdModal extends StatefulWidget {
  final Function(AdModel) onAdCreated;

  const CreateAdModal({super.key, required this.onAdCreated});

  @override
  State<CreateAdModal> createState() => _CreateAdModalState();
}

class _CreateAdModalState extends State<CreateAdModal> {
  final TextEditingController _titleController = TextEditingController();
  bool _isUrlUpload = true;
  String _imageUrl = '';
  PlatformFile? _pickedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _imageUrl = ''; // Clear any existing URL input
        _isUrlUpload = false;
      });
    }
  }

  void _submit() {
    String title = _titleController.text.trim();
    if (title.isEmpty || (_isUrlUpload && _imageUrl.isEmpty && _pickedFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and an image.')),
      );
      return;
    }

    String imagePath = _isUrlUpload
        ? _imageUrl
        : _pickedFile != null
            ? _pickedFile!.path!
            : '';

    final newAd = AdModel(
      title: title,
      imageUrl: imagePath,
      status: 'Active',
      impressions: 0,
    );

    widget.onAdCreated(newAd);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: isWide ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create New Ad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [_isUrlUpload, !_isUrlUpload],
                onPressed: (index) {
                  setState(() {
                    _isUrlUpload = index == 0;
                    _pickedFile = null;
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("URL Upload")),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("File Upload")),
                ],
              ),
              const SizedBox(height: 16),
              _isUrlUpload
                  ? TextField(
                      onChanged: (val) => setState(() => _imageUrl = val),
                      decoration: const InputDecoration(
                        labelText: "Image URL",
                        border: OutlineInputBorder(),
                      ),
                    )
                  : GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        alignment: Alignment.center,
                        child: _pickedFile == null
                            ? const Text("Tap to pick image file")
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image, color: Colors.green),
                                  const SizedBox(height: 8),
                                  Text(_pickedFile!.name),
                                ],
                              ),
                      ),
                    ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create Ad", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

