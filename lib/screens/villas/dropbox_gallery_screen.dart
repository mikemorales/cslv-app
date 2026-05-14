import 'package:flutter/material.dart';

import '../../services/villa_service.dart';

class DropboxGalleryScreen extends StatefulWidget {
  final int villaId;
  final String? initialUrl;

  const DropboxGalleryScreen({
    super.key,
    required this.villaId,
    this.initialUrl,
  });

  @override
  State<DropboxGalleryScreen> createState() => _DropboxGalleryScreenState();
}

class _DropboxGalleryScreenState extends State<DropboxGalleryScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _images = [];
  Set<int> _selectedIndexes = {};
  String? _featuredUrl;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _urlController.text =
        widget.initialUrl ?? await villaService.getDropboxGalleryUrl(widget.villaId) ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropbox Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Dropbox Folder URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _isLoading ? null : _fetchImages,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Fetch Images'),
              ),
              const SizedBox(width: 12),
              if (_images.isNotEmpty)
                Text('${_selectedIndexes.length} selected'),
            ],
          ),
          const SizedBox(height: 16),
          ..._images.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            final selected = _selectedIndexes.contains(index);
            final imageUrl = image['url']?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: CheckboxListTile(
                value: selected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIndexes.add(index);
                    } else {
                      _selectedIndexes.remove(index);
                    }
                  });
                },
                title: Text(image['name']?.toString() ?? 'Image'),
                subtitle: Text(imageUrl),
                secondary: IconButton(
                  onPressed: selected
                      ? () => setState(() => _featuredUrl = imageUrl)
                      : null,
                  icon: Icon(
                    _featuredUrl == imageUrl ? Icons.star : Icons.star_border,
                  ),
                ),
              ),
            );
          }),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSaving ? null : _saveGallery,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Gallery'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _fetchImages() async {
    final dropboxUrl = _urlController.text.trim();
    if (dropboxUrl.isEmpty) {
      _showMessage('Dropbox URL is required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final images = await villaService.fetchDropboxImages(dropboxUrl);
      if (!mounted) {
        return;
      }

      setState(() {
        _images = images;
        _selectedIndexes = images.isEmpty
            ? {}
            : Set<int>.from(List.generate(images.length, (index) => index));
        _featuredUrl =
            images.isNotEmpty ? images.first['url']?.toString() : null;
      });
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveGallery() async {
    if (_selectedIndexes.isEmpty) {
      _showMessage('Select at least one image.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final selectedImages = _selectedIndexes.toList()..sort();
      final payload = selectedImages.asMap().entries.map((entry) {
        final image = _images[entry.value];
        return {
          'filename': image['name']?.toString() ?? 'image_${entry.key}',
          'dropbox_url': image['url']?.toString() ?? '',
          'display_order': entry.key,
        };
      }).toList();

      await villaService.saveDropboxGalleryData(
        widget.villaId,
        dropboxUrl: _urlController.text.trim(),
        images: payload,
        featuredImage: _featuredUrl,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
