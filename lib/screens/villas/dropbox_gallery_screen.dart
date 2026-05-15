import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/villa.dart';
import '../../services/villa_service.dart';

class DropboxGalleryScreen extends StatefulWidget {
  final int villaId;
  final String? villaTitle;

  const DropboxGalleryScreen({
    super.key,
    required this.villaId,
    this.villaTitle,
  });

  @override
  State<DropboxGalleryScreen> createState() => _DropboxGalleryScreenState();
}

class _DropboxGalleryScreenState extends State<DropboxGalleryScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _dropboxUrl;
  List<VillaImage> _images = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        villaService.getVilla(widget.villaId),
        villaService.getDropboxGalleryUrl(widget.villaId),
      ]);

      final villa = results[0] as Villa;
      final galleryUrl = results[1] as String?;
      final sortedImages = [...?villa.images]
        ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

      if (!mounted) {
        return;
      }

      setState(() {
        _dropboxUrl = galleryUrl;
        _images = sortedImages;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Villa Gallery Order')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  if (widget.villaTitle != null &&
                      widget.villaTitle!.isNotEmpty)
                    ListTile(
                      title: Text(widget.villaTitle!),
                      subtitle: Text('Reorder existing villa images only'),
                    ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _ErrorCard(message: _errorMessage!),
                    ),
                  Expanded(
                    child: _images.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'This villa has no saved gallery images.',
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            padding: const EdgeInsets.all(16),
                            itemCount: _images.length,
                            onReorder: _reorder,
                            itemBuilder: (context, index) {
                              final image = _images[index];
                              final url = _resolveImageUrl(
                                image.dropboxUrlImage ?? '',
                              );

                              return Card(
                                key: ValueKey(image.id),
                                margin: const EdgeInsets.only(bottom: 12),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _ImagePreview(url: url),
                                      ),
                                      const SizedBox(width: 12),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${index + 1}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            const Icon(Icons.drag_handle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                          onPressed: _isSaving ? null : _saveOrder,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving ? 'Saving Order...' : 'Save Order',
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
    if (_dropboxUrl == null || _dropboxUrl!.trim().isEmpty) {
      _showMessage('This villa does not have a saved Dropbox gallery URL.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = _images.asMap().entries.map((entry) {
        final image = entry.value;
        final sourceUrl = image.dropboxUrlImage ?? '';
        return {
          'filename': _filenameFromUrl(sourceUrl),
          'dropbox_url': sourceUrl,
          'display_order': entry.key,
        };
      }).toList();

      await villaService.saveDropboxGalleryData(
        widget.villaId,
        dropboxUrl: _dropboxUrl!.trim(),
        images: payload,
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

  String _resolveImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return '${ApiConfig.baseUrl}$url';
  }

  String _filenameFromUrl(String url) {
    final sanitized = url.split('?').first;
    final segments = sanitized.split('/');
    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }

    return 'image';
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
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 140,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined),
          );
        },
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
