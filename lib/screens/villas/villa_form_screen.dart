import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../models/villa.dart';
import '../../services/category_service.dart';
import '../../services/tag_service.dart';
import '../../services/villa_service.dart';
import '../../utils/validators.dart';
import 'dropbox_gallery_screen.dart';
import 'seasonal_rates_screen.dart';

class VillaFormScreen extends StatefulWidget {
  final Villa? villa;

  const VillaFormScreen({super.key, this.villa});

  bool get isEditing => villa != null;

  @override
  State<VillaFormScreen> createState() => _VillaFormScreenState();
}

class _VillaFormScreenState extends State<VillaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _permalinkController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _sleepsController = TextEditingController();
  final _sqftController = TextEditingController();
  final _viewController = TextEditingController();
  final _icalUrlController = TextEditingController();
  final _taxesController = TextEditingController();
  final _damageWaiverController = TextEditingController();
  final _accommodationController = TextEditingController();
  final _hoaFeeController = TextEditingController();

  bool _isLoading = false;
  bool _isBootstrapping = true;
  String? _status;
  int? _categoryId;
  List<int> _selectedTags = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tags = [];

  @override
  void initState() {
    super.initState();
    _fillInitialValues();
    _loadOptions();
  }

  void _fillInitialValues() {
    final villa = widget.villa;
    if (villa == null) {
      _status = AppConstants.villaStatuses.first;
      _taxesController.text = '0';
      _damageWaiverController.text = '0';
      _accommodationController.text = '0';
      _hoaFeeController.text = '0';
      return;
    }

    _titleController.text = villa.title;
    _slugController.text = villa.slug;
    _permalinkController.text = villa.permalink ?? '';
    _excerptController.text = villa.excerpt ?? '';
    _contentController.text = villa.content ?? '';
    _priceController.text = villa.price.toString();
    _bathroomsController.text = villa.bathrooms.toString();
    _bedroomsController.text = villa.bedrooms.toString();
    _sleepsController.text = villa.sleeps.toString();
    _sqftController.text = villa.sqft?.toString() ?? '';
    _viewController.text = villa.view ?? '';
    _icalUrlController.text = villa.icalUrl ?? '';
    _taxesController.text = villa.taxesAndFees?.toString() ?? '0';
    _damageWaiverController.text = villa.damageWaiver?.toString() ?? '0';
    _accommodationController.text =
        villa.accommodationTaxesFees?.toString() ?? '0';
    _hoaFeeController.text = villa.hoaFee?.toString() ?? '0';
    _status = villa.status;
    _categoryId = villa.categoryId;
    _selectedTags = villa.tags?.map((tag) => tag.id).toList() ?? [];
  }

  Future<void> _loadOptions() async {
    try {
      final categories = await categoryService.getFlatHierarchy();
      final tags = await tagService.getTags();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _tags = tags;
        _categoryId ??= categories.isNotEmpty
            ? (categories.first['id'] as num).toInt()
            : null;
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
    _permalinkController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    _priceController.dispose();
    _bathroomsController.dispose();
    _bedroomsController.dispose();
    _sleepsController.dispose();
    _sqftController.dispose();
    _viewController.dispose();
    _icalUrlController.dispose();
    _taxesController.dispose();
    _damageWaiverController.dispose();
    _accommodationController.dispose();
    _hoaFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Villa' : 'Create Villa'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _generatePermalink,
            child: const Text('Permalink'),
          ),
        ],
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      validator: (value) =>
                          AppValidators.requiredField(value, field: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: (item['id'] as num).toInt(),
                              child: Text(item['label']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _categoryId = value),
                      validator: (value) =>
                          value == null ? 'Category is required.' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _slugController,
                            label: 'Slug',
                            validator: (value) => AppValidators.requiredField(
                              value,
                              field: 'Slug',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _isLoading ? null : _generatePermalink,
                          icon: const Icon(Icons.auto_fix_high),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _permalinkController,
                      label: 'Permalink',
                      validator: (value) => AppValidators.requiredField(
                        value,
                        field: 'Permalink',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.villaStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _status = value),
                    ),
                    const SizedBox(height: 16),
                    _buildTagSelector(context),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _excerptController,
                      label: 'Excerpt',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _contentController,
                      label: 'Content',
                      maxLines: 6,
                    ),
                    const SizedBox(height: 16),
                    _buildNumberGrid(),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _viewController, label: 'View'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _icalUrlController,
                      label: 'iCal URL',
                    ),
                    const SizedBox(height: 16),
                    _buildFeeGrid(),
                    if (widget.isEditing) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _openDropboxGallery,
                              child: const Text('Dropbox Gallery'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _openSeasonalRates,
                              child: const Text('Seasonal Rates'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Update Villa'
                                  : 'Create Villa',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTagSelector(BuildContext context) {
    final labels = _tags
        .where((tag) => _selectedTags.contains((tag['id'] as num).toInt()))
        .map((tag) => tag['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    return InkWell(
      onTap: _isLoading ? null : () => _openTagPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tags',
          border: OutlineInputBorder(),
        ),
        child: Text(labels.isEmpty ? 'Select tags' : labels),
      ),
    );
  }

  Widget _buildNumberGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumberValidator('Price'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _bathroomsController,
                label: 'Bathrooms',
                keyboardType: TextInputType.number,
                validator: _requiredNumberValidator('Bathrooms'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _bedroomsController,
                label: 'Bedrooms',
                keyboardType: TextInputType.number,
                validator: _requiredNumberValidator('Bedrooms'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _sleepsController,
                label: 'Sleeps',
                keyboardType: TextInputType.number,
                validator: _requiredNumberValidator('Sleeps'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _sqftController,
          label: 'Sqft',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildFeeGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _taxesController,
                label: 'Taxes & Fees',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumberValidator('Taxes & Fees'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _damageWaiverController,
                label: 'Damage Waiver',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumberValidator('Damage Waiver'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _accommodationController,
                label: 'Accommodation Taxes',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumberValidator('Accommodation Taxes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _hoaFeeController,
                label: 'HOA Fee',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _requiredNumberValidator('HOA Fee'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  String? Function(String?) _requiredNumberValidator(String label) {
    return (value) {
      final required = AppValidators.requiredField(value, field: label);
      if (required != null) {
        return required;
      }

      if (num.tryParse(value!.trim()) == null) {
        return '$label must be numeric.';
      }

      return null;
    };
  }

  Future<void> _generatePermalink() async {
    if (_titleController.text.trim().isEmpty || _categoryId == null) {
      _showMessage('Title and category are required to generate permalink.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await villaService.generatePermalink(
        title: _titleController.text.trim(),
        categoryId: _categoryId!,
        villaId: widget.villa?.id,
      );

      _slugController.text = response['slug']?.toString() ?? '';
      _permalinkController.text = response['permalink']?.toString() ?? '';
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'title': _titleController.text.trim(),
        'slug': _slugController.text.trim(),
        'link': _permalinkController.text.trim(),
        'excerpt': _emptyToNull(_excerptController.text),
        'content': _emptyToNull(_contentController.text),
        'status': _status,
        'price': _parseNum(_priceController.text),
        'bathrooms': _parseInt(_bathroomsController.text),
        'bedrooms': _parseInt(_bedroomsController.text),
        'sleeps': _parseInt(_sleepsController.text),
        'sqft': _parseNullableInt(_sqftController.text),
        'view': _emptyToNull(_viewController.text),
        'ical_url': _emptyToNull(_icalUrlController.text),
        'taxes_and_fees': _parseNum(_taxesController.text),
        'damage_waiver': _parseNum(_damageWaiverController.text),
        'accommodation_taxes_fees': _parseNum(_accommodationController.text),
        'hoa_fee': _parseNum(_hoaFeeController.text),
        'category_id': _categoryId,
        'tags': _selectedTags,
      };

      if (widget.isEditing) {
        await villaService.updateVilla(widget.villa!.id, payload);
      } else {
        await villaService.createVilla(payload);
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

  Future<void> _openTagPicker(BuildContext context) async {
    final tempSelected = [..._selectedTags];

    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select tags'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _tags.map((tag) {
                      final id = (tag['id'] as num).toInt();
                      final checked = tempSelected.contains(id);

                      return CheckboxListTile(
                        value: checked,
                        title: Text(tag['name']?.toString() ?? ''),
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

    if (result != null && mounted) {
      setState(() => _selectedTags = result);
    }
  }

  num _parseNum(String value) => num.parse(value.trim());
  int _parseInt(String value) => int.parse(value.trim());
  int? _parseNullableInt(String value) =>
      value.trim().isEmpty ? null : int.parse(value.trim());
  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _openDropboxGallery() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DropboxGalleryScreen(
          villaId: widget.villa!.id,
          villaTitle: widget.villa!.title,
        ),
      ),
    );

    if (result == true && mounted) {
      _showMessage('Dropbox gallery saved.');
    }
  }

  Future<void> _openSeasonalRates() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SeasonalRatesScreen(
          villaId: widget.villa!.id,
          villaTitle: widget.villa!.title,
        ),
      ),
    );

    if (result == true && mounted) {
      _showMessage('Seasonal rates saved.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
