import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../models/administrator.dart';
import '../../services/administrator_service.dart';
import '../../utils/validators.dart';

class AdministratorFormScreen extends StatefulWidget {
  final Administrator? administrator;

  const AdministratorFormScreen({super.key, this.administrator});

  bool get isEditing => administrator != null;

  @override
  State<AdministratorFormScreen> createState() =>
      _AdministratorFormScreenState();
}

class _AdministratorFormScreenState extends State<AdministratorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _isLoading = false;
  String _role = AppConstants.roles.first;

  @override
  void initState() {
    super.initState();
    final admin = widget.administrator;
    if (admin != null) {
      _nameController.text = admin.name;
      _emailController.text = admin.email;
      _role = admin.roles?.isNotEmpty == true
          ? admin.roles!.first.name
          : AppConstants.roles.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? 'Edit Administrator' : 'New Administrator'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    AppValidators.requiredField(value, field: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: AppValidators.email,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _role = value ?? _role),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText:
                      widget.isEditing ? 'Password (optional)' : 'Password',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (widget.isEditing && (value == null || value.isEmpty)) {
                    return null;
                  }

                  return AppValidators.password(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordConfirmationController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (widget.isEditing &&
                      _passwordController.text.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return null;
                  }

                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }

                  return null;
                },
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
                    : Text(
                        widget.isEditing
                            ? 'Update Administrator'
                            : 'Create Administrator',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _role,
      };

      if (_passwordController.text.isNotEmpty) {
        payload['password'] = _passwordController.text;
        payload['password_confirmation'] = _passwordConfirmationController.text;
      }

      if (widget.isEditing) {
        await administratorService.updateAdministrator(
          widget.administrator!.id,
          payload,
        );
      } else {
        await administratorService.createAdministrator(payload);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
