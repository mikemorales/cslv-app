import 'package:flutter/material.dart';

import '../../services/villa_service.dart';

class SeasonalRatesScreen extends StatefulWidget {
  final int villaId;
  final String? villaTitle;

  const SeasonalRatesScreen({
    super.key,
    required this.villaId,
    this.villaTitle,
  });

  @override
  State<SeasonalRatesScreen> createState() => _SeasonalRatesScreenState();
}

class _SeasonalRatesScreenState extends State<SeasonalRatesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _rates = [];

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rates = await villaService.getSeasonalRatesRaw(widget.villaId);
      if (!mounted) {
        return;
      }

      setState(() {
        _rates = _sortForDisplay(rates);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seasonal Rates')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  if (widget.villaTitle != null &&
                      widget.villaTitle!.isNotEmpty)
                    ListTile(
                      title: Text(widget.villaTitle!),
                      subtitle: const Text('Edit existing villa rates only'),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ErrorCard(message: _errorMessage!),
                          ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: _addRate,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Season'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_rates.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No seasonal rates configured yet.'),
                            ),
                          )
                        else
                          ..._rates.asMap().entries.map((entry) {
                            final rate = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  '${rate['start_date']} - ${rate['end_date']}',
                                ),
                                subtitle: Text(
                                  'Night: ${rate['price_per_night']} | Weekend: ${rate['weekend_rate'] ?? '-'} | Min nights: ${rate['minimum_nights']}',
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      onPressed: () => _editRate(entry.key),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeRate(entry.key),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveRates,
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
                          _isSaving ? 'Saving Rates...' : 'Save Rates',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _addRate() async {
    final result = await _openRateEditor();
    if (result != null && mounted) {
      setState(() => _rates = _sortForDisplay([..._rates, result]));
    }
  }

  Future<void> _editRate(int index) async {
    final result = await _openRateEditor(initial: _rates[index]);
    if (result != null && mounted) {
      final updated = [..._rates];
      updated[index] = result;
      setState(() => _rates = _sortForDisplay(updated));
    }
  }

  void _removeRate(int index) {
    final updated = [..._rates]..removeAt(index);
    setState(() => _rates = updated);
  }

  Future<Map<String, dynamic>?> _openRateEditor({
    Map<String, dynamic>? initial,
  }) async {
    DateTime? startDate = _parseDate(initial?['start_date']?.toString());
    DateTime? endDate = _parseDate(initial?['end_date']?.toString());
    final priceController = TextEditingController(
      text: initial?['price_per_night']?.toString() ?? '',
    );
    final weekendController = TextEditingController(
      text: initial?['weekend_rate']?.toString() ?? '',
    );
    final minNightsController = TextEditingController(
      text: initial?['minimum_nights']?.toString() ?? '1',
    );
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate({required bool isStart}) async {
              final initialDate =
                  (isStart ? startDate : endDate) ?? DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );

              if (picked == null) {
                return;
              }

              setDialogState(() {
                if (isStart) {
                  startDate = picked;
                  if (endDate != null && !endDate!.isAfter(startDate!)) {
                    endDate = null;
                  }
                } else {
                  endDate = picked;
                }
              });
            }

            return AlertDialog(
              title: Text(initial == null ? 'Add Season' : 'Edit Season'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DatePickerField(
                          label: 'Start Date',
                          value: startDate == null
                              ? null
                              : _formatDate(startDate!),
                          onTap: () => pickDate(isStart: true),
                        ),
                        const SizedBox(height: 12),
                        _DatePickerField(
                          label: 'End Date',
                          value: endDate == null ? null : _formatDate(endDate!),
                          onTap: () => pickDate(isStart: false),
                        ),
                        const SizedBox(height: 12),
                        _rateField(
                          priceController,
                          'Price Per Night',
                          isNumeric: true,
                        ),
                        const SizedBox(height: 12),
                        _rateField(
                          weekendController,
                          'Weekend Rate',
                          isNumeric: true,
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _rateField(
                          minNightsController,
                          'Minimum Nights',
                          isNumeric: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    if (startDate == null || endDate == null) {
                      _showMessage('Start and end dates are required.');
                      return;
                    }
                    if (!endDate!.isAfter(startDate!)) {
                      _showMessage('End date must be after start date.');
                      return;
                    }

                    Navigator.of(context).pop({
                      'id':
                          initial?['id'] ??
                          'temp_${DateTime.now().millisecondsSinceEpoch}',
                      'start_date': _formatDate(startDate!),
                      'end_date': _formatDate(endDate!),
                      'price_per_night': num.parse(priceController.text.trim()),
                      'weekend_rate': weekendController.text.trim().isEmpty
                          ? null
                          : num.parse(weekendController.text.trim()),
                      'minimum_nights': int.parse(
                        minNightsController.text.trim(),
                      ),
                    });
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _rateField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required.';
        }

        if (isNumeric && value != null && value.trim().isNotEmpty) {
          if (num.tryParse(value.trim()) == null) {
            return '$label must be numeric.';
          }
        }

        return null;
      },
    );
  }

  Future<void> _saveRates() async {
    final validationError = _validateRates();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await villaService.saveSeasonalRatesRaw(
        widget.villaId,
        _sortForSave(_rates),
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

  String? _validateRates() {
    if (_rates.isEmpty) {
      return 'You must add at least one season.';
    }

    final sorted = _sortForSave(_rates);
    for (var index = 0; index < sorted.length; index++) {
      final rate = sorted[index];
      final start = _parseDate(rate['start_date']?.toString());
      final end = _parseDate(rate['end_date']?.toString());
      final price =
          num.tryParse(rate['price_per_night']?.toString() ?? '') ?? 0;
      final minimum =
          int.tryParse(rate['minimum_nights']?.toString() ?? '') ?? 0;

      if (start == null || end == null) {
        return 'All seasons must have start and end dates.';
      }
      if (!end.isAfter(start)) {
        return 'End date must be after start date.';
      }
      if (price <= 0) {
        return 'Price per night must be greater than 0.';
      }
      if (minimum < 1) {
        return 'Minimum nights must be at least 1.';
      }

      if (index > 0) {
        final previousEnd = _parseDate(
          sorted[index - 1]['end_date']?.toString(),
        );
        if (previousEnd != null && !start.isAfter(previousEnd)) {
          return 'There are seasons with overlapping dates.';
        }
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _sortForDisplay(List<Map<String, dynamic>> rates) {
    final sorted = [...rates]
      ..sort((a, b) {
        final left = _parseDate(a['start_date']?.toString()) ?? DateTime(1970);
        final right = _parseDate(b['start_date']?.toString()) ?? DateTime(1970);
        return right.compareTo(left);
      });
    return sorted;
  }

  List<Map<String, dynamic>> _sortForSave(List<Map<String, dynamic>> rates) {
    final sorted = [...rates]
      ..sort((a, b) {
        final left = _parseDate(a['start_date']?.toString()) ?? DateTime(1970);
        final right = _parseDate(b['start_date']?.toString()) ?? DateTime(1970);
        return left.compareTo(right);
      });
    return sorted;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value ?? 'Select date'),
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
