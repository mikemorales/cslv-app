import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/administrator.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/state_views.dart';
import 'administrator_form_screen.dart';

class AdministratorsListScreen extends ConsumerStatefulWidget {
  const AdministratorsListScreen({super.key});

  @override
  ConsumerState<AdministratorsListScreen> createState() =>
      _AdministratorsListScreenState();
}

class _AdministratorsListScreenState
    extends ConsumerState<AdministratorsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search administrators',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    ref.read(adminProvider.notifier).load(search: value.trim());
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(state)),
      ],
    );
  }

  Widget _buildContent(AdminState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingView();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyView(message: 'No administrators found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final admin = state.items[index];
        final roles = admin.roles?.map((role) => role.name).join(', ') ?? '-';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => _openEditForm(admin),
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(admin.name),
            subtitle: Text('${admin.email}\n$roles'),
            isThreeLine: true,
            trailing: const Icon(Icons.edit_outlined),
          ),
        );
      },
    );
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AdministratorFormScreen()),
    );

    if (result == true && mounted) {
      ref.read(adminProvider.notifier).load(
            search: _searchController.text.trim(),
          );
    }
  }

  Future<void> _openEditForm(Administrator administrator) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdministratorFormScreen(administrator: administrator),
      ),
    );

    if (result == true && mounted) {
      ref.read(adminProvider.notifier).load(
            search: _searchController.text.trim(),
          );
    }
  }
}
