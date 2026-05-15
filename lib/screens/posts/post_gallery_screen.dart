import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';

class PostGalleryScreen extends StatefulWidget {
  final Post post;

  const PostGalleryScreen({super.key, required this.post});

  @override
  State<PostGalleryScreen> createState() => _PostGalleryScreenState();
}

class _PostGalleryScreenState extends State<PostGalleryScreen> {
  bool _isSavingOrder = false;
  late List<PostImage> _images;

  @override
  void initState() {
    super.initState();
    _images = [...?widget.post.images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Gallery Order')),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(widget.post.title),
              subtitle: const Text('Reorder existing post images only'),
            ),
            Expanded(
              child: _images.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('This post has no gallery images.'),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _images.length,
                      onReorder: _reorder,
                      itemBuilder: (context, index) {
                        final image = _images[index];
                        return Card(
                          key: ValueKey(image.id),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: _ImagePreview(
                              url: _resolveImageUrl(image.imagePath),
                            ),
                            title: Text('Image #${index + 1}'),
                            subtitle: Text(image.imagePath),
                            trailing: const Icon(Icons.drag_handle),
                          ),
                        );
                      },
                    ),
            ),
            if (_images.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: _isSavingOrder ? null : _saveOrder,
                    icon: _isSavingOrder
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isSavingOrder ? 'Saving Order...' : 'Save Order',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      final updated = [..._images];
      final item = updated.removeAt(oldIndex);
      updated.insert(newIndex, item);
      _images = updated;
    });
  }

  Future<void> _saveOrder() async {
    setState(() => _isSavingOrder = true);
    try {
      await postService.reorderGallery(
        widget.post.id,
        _images.asMap().entries.map((entry) {
          return {'id': entry.value.id, 'sort_order': entry.key};
        }).toList(),
      );
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

  String _resolveImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '${ApiConfig.baseUrl}$path';
    }

    return '${ApiConfig.baseUrl}/storage/$path';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ImagePreview extends StatelessWidget {
  final String url;

  const _ImagePreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) {
          return Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined),
          );
        },
      ),
    );
  }
}
