import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';

class PostGalleryScreen extends StatefulWidget {
  final Post post;

  const PostGalleryScreen({super.key, required this.post});

  @override
  State<PostGalleryScreen> createState() => _PostGalleryScreenState();
}

class _PostGalleryScreenState extends State<PostGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isSavingOrder = false;
  late List<Map<String, dynamic>> _images;

  @override
  void initState() {
    super.initState();
    _images = (widget.post.images ?? [])
        .map(
          (image) => {
            'id': image.id,
            'url': image.imagePath,
            'sort_order': image.sortOrder,
            'is_featured': image.isFeatured,
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Gallery'),
        actions: [
          IconButton(
            onPressed: _isUploading ? null : _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_images.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No gallery images yet.')),
            ),
          ..._images.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Image #${index + 1}'),
                subtitle: Text(image['url']?.toString() ?? ''),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      onPressed: index == 0 ? null : () => _move(index, index - 1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      onPressed: index == _images.length - 1
                          ? null
                          : () => _move(index, index + 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      onPressed: () => _delete(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSavingOrder ? null : _saveOrder,
              child: _isSavingOrder
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Order'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) {
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploaded = <Map<String, dynamic>>[];
      for (final file in files) {
        final response = await postService.uploadGalleryImage(widget.post.id, file);
        uploaded.add({
          'id': response['id'],
          'url': response['url'],
          'sort_order': response['sort_order'],
          'is_featured': response['is_featured'],
        });
      }

      if (!mounted) {
        return;
      }

      setState(() => _images = [..._images, ...uploaded]);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _move(int from, int to) {
    final updated = [..._images];
    final item = updated.removeAt(from);
    updated.insert(to, item);

    for (var i = 0; i < updated.length; i++) {
      updated[i]['sort_order'] = i;
    }

    setState(() => _images = updated);
  }

  Future<void> _delete(int index) async {
    final image = _images[index];
    try {
      await postService.deleteGalleryImage(widget.post.id, image['id'] as int);
      final updated = [..._images]..removeAt(index);
      for (var i = 0; i < updated.length; i++) {
        updated[i]['sort_order'] = i;
      }
      if (!mounted) {
        return;
      }
      setState(() => _images = updated);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _saveOrder() async {
    setState(() => _isSavingOrder = true);
    try {
      await postService.reorderGallery(widget.post.id, _images);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSavingOrder = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
