import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_constants.dart';
import '../../models/post.dart';
import '../../services/category_service.dart';
import '../../services/post_service.dart';
import '../../services/tag_service.dart';
import '../../utils/validators.dart';
import 'post_gallery_screen.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  bool get isEditing => post != null;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _excerptController = TextEditingController();
  final _seoTitleController = TextEditingController();
  final _seoDescriptionController = TextEditingController();
  final _seoKeywordsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isBootstrapping = true;
  String _contentHtml = '';
  String _status = AppConstants.postStatuses.first;
  List<int> _selectedCategories = [];
  List<int> _selectedTags = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tags = [];
  XFile? _featuredImage;

  @override
  void initState() {
    super.initState();
    _fillInitialValues();
    _loadOptions();
  }

  void _fillInitialValues() {
    final post = widget.post;
    if (post == null) {
      _status = 'draft';
      return;
    }

    _titleController.text = post.title;
    _slugController.text = post.slug;
    _excerptController.text = post.excerpt ?? '';
    _contentHtml = post.content ?? '';
    _status = post.status;
    _selectedCategories = post.categories?.map((item) => item.id).toList() ?? [];
    _selectedTags = post.tags?.map((item) => item.id).toList() ?? [];
  }

  Future<void> _loadOptions() async {
    try {
      final categories = await categoryService.getFlatHierarchy(type: 'post');
      final tags = await tagService.getTags();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _tags = tags;
        _isBootstrapping = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isBootstrapping = false);
      _showMessage(error.toString());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _excerptController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _seoKeywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Post' : 'Create Post'),
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          AppValidators.requiredField(value, field: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _slugController,
                      decoration: const InputDecoration(
                        labelText: 'Slug',
                        border: OutlineInputBorder(),
                      ),
                      validator: widget.isEditing
                          ? (value) =>
                              AppValidators.requiredField(value, field: 'Slug')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.postStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _status = value ?? _status),
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelector(
                      label: 'Categories',
                      items: _categories,
                      selectedIds: _selectedCategories,
                      onTap: () => _pickItems(
                        title: 'Select categories',
                        items: _categories,
                        selectedIds: _selectedCategories,
                        onApply: (values) =>
                            setState(() => _selectedCategories = values),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelector(
                      label: 'Tags',
                      items: _tags,
                      selectedIds: _selectedTags,
                      onTap: () => _pickItems(
                        title: 'Select tags',
                        items: _tags,
                        selectedIds: _selectedTags,
                        onApply: (values) => setState(() => _selectedTags = values),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImageSelector(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _excerptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Excerpt',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContentField(),
                    if (widget.isEditing) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _openGallery,
                        child: const Text('Manage Gallery'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _seoTitleController,
                      decoration: const InputDecoration(
                        labelText: 'SEO Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _seoDescriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'SEO Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _seoKeywordsController,
                      decoration: const InputDecoration(
                        labelText: 'SEO Keywords',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.isEditing ? 'Update Post' : 'Create Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMultiSelector({
    required String label,
    required List<Map<String, dynamic>> items,
    required List<int> selectedIds,
    required VoidCallback onTap,
  }) {
    final labels = items
        .where((item) => selectedIds.contains((item['id'] as num).toInt()))
        .map((item) => item['label']?.toString() ?? item['name']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .join(', ');

    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(labels.isEmpty ? 'Select $label' : labels),
      ),
    );
  }

  Widget _buildImageSelector() {
    final hasCurrent = widget.post?.featuredImageUrl != null &&
        widget.post!.featuredImageUrl!.isNotEmpty;
    final imageLabel = _featuredImage != null
        ? _featuredImage!.name
        : hasCurrent
            ? 'Current image available'
            : 'Select featured image';

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.isEditing
            ? 'Featured Image (optional)'
            : 'Featured Image',
        border: const OutlineInputBorder(),
        errorText: !widget.isEditing && _featuredImage == null ? null : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(imageLabel)),
          TextButton.icon(
            onPressed: _isLoading ? null : _pickFeaturedImage,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Choose'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    final preview = _contentHtml
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Content',
            border: OutlineInputBorder(),
          ),
          child: Text(
            preview.isEmpty
                ? 'Content is managed in the web manager only.'
                : preview,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Content cannot be edited in the app. Use the web manager.',
        ),
      ],
    );
  }

  Future<void> _pickFeaturedImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() => _featuredImage = image);
    }
  }

  Future<void> _pickItems({
    required String title,
    required List<Map<String, dynamic>> items,
    required List<int> selectedIds,
    required ValueChanged<List<int>> onApply,
  }) async {
    final tempSelected = [...selectedIds];

    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((item) {
                      final id = (item['id'] as num).toInt();
                      final checked = tempSelected.contains(id);
                      final label = item['label']?.toString() ??
                          item['name']?.toString() ??
                          '';

                      return CheckboxListTile(
                        value: checked,
                        title: Text(label),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(id);
                            } else {
                              tempSelected.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(tempSelected),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      onApply(result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!widget.isEditing && _featuredImage == null) {
      _showMessage('Featured image is required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final content = _contentHtml.trim();
      if (content.isEmpty) {
        throw Exception('Content is required.');
      }

      final payload = <String, dynamic>{
        'title': _titleController.text.trim(),
        'content': content,
        'excerpt': _emptyToNull(_excerptController.text),
        'status': _status,
        'slug': widget.isEditing ? _slugController.text.trim() : null,
        'categories': _selectedCategories,
        'tags': _selectedTags,
        'seo_title': _emptyToNull(_seoTitleController.text),
        'seo_description': _emptyToNull(_seoDescriptionController.text),
        'seo_keywords': _emptyToNull(_seoKeywordsController.text),
        if (_featuredImage != null) 'featured_image': _featuredImage,
      };

      if (widget.isEditing) {
        await postService.updatePost(widget.post!.id, payload);
      } else {
        await postService.createPost(payload);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _openGallery() async {
    final postId = widget.post?.id;
    if (postId == null) {
      return;
    }

    final freshPost = await postService.getPost(postId);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PostGalleryScreen(post: freshPost),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
