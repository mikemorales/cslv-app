import 'package:flutter/material.dart';

import '../../services/villa_service.dart';

class SeasonalRatesScreen extends StatefulWidget {
  final int villaId;

  const SeasonalRatesScreen({super.key, required this.villaId});

  @override
  State<SeasonalRatesScreen> createState() => _SeasonalRatesScreenState();
}

class _SeasonalRatesScreenState extends State<SeasonalRatesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _rates = [];

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    try {
      final rates = await villaService.getSeasonalRatesRaw(widget.villaId);
      if (!mounted) {
        return;
      }

      setState(() {
        _rates = rates;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      _showMessage(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seasonal Rates'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _addRate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._rates.asMap().entries.map((entry) {
                  final index = entry.key;
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
                        spacing: 8,
                        children: [
                          IconButton(
                            onPressed: () => _editRate(index),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => _removeRate(index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isSaving ? null : _saveRates,
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Rates'),
                ),
              ],
            ),
    );
  }

  Future<void> _addRate() async {
    final result = await _openRateEditor();
    if (result != null && mounted) {
      setState(() => _rates = [..._rates, result]);
    }
  }

  Future<void> _editRate(int index) async {
    final result = await _openRateEditor(initial: _rates[index]);
    if (result != null && mounted) {
      final updated = [..._rates];
      updated[index] = result;
      setState(() => _rates = updated);
    }
  }

  void _removeRate(int index) {
    final updated = [..._rates]..removeAt(index);
    setState(() => _rates = updated);
  }

  Future<Map<String, dynamic>?> _openRateEditor({
    Map<String, dynamic>? initial,
  }) async {
    final formKey = GlobalKey<FormState>();
    final startController = TextEditingController(
      text: initial?['start_date']?.toString() ?? '',
    );
    final endController = TextEditingController(
      text: initial?['end_date']?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: initial?['price_per_night']?.toString() ?? '',
    );
    final weekendController = TextEditingController(
      text: initial?['weekend_rate']?.toString() ?? '',
    );
    final minNightsController = TextEditingController(
      text: initial?['minimum_nights']?.toString() ?? '1',
    );

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initial == null ? 'Add Rate' : 'Edit Rate'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _rateField(startController, 'Start Date (YYYY-MM-DD)'),
                    const SizedBox(height: 12),
                    _rateField(endController, 'End Date (YYYY-MM-DD)'),
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

                Navigator.of(context).pop({
                  'id': initial?['id'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  'start_date': startController.text.trim(),
                  'end_date': endController.text.trim(),
                  'price_per_night': num.parse(priceController.text.trim()),
                  'weekend_rate': weekendController.text.trim().isEmpty
                      ? null
                      : num.parse(weekendController.text.trim()),
                  'minimum_nights': int.parse(minNightsController.text.trim()),
                });
              },
              child: const Text('Apply'),
            ),
          ],
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
    setState(() => _isSaving = true);
    try {
      await villaService.saveSeasonalRatesRaw(widget.villaId, _rates);
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
