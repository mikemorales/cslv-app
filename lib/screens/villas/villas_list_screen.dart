import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/villa.dart';
import '../../providers/villa_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/state_views.dart';
import 'villa_form_screen.dart';

class VillasListScreen extends ConsumerStatefulWidget {
  const VillasListScreen({super.key});

  @override
  ConsumerState<VillasListScreen> createState() => _VillasListScreenState();
}

class _VillasListScreenState extends ConsumerState<VillasListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(villaProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(villaProvider);

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
                    labelText: 'Search villas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    ref.read(villaProvider.notifier).load(search: value.trim());
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => ref.read(villaProvider.notifier).load(
                      search: _searchController.text.trim(),
                    ),
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
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

  Widget _buildContent(VillaState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingView();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(villaProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyView(message: 'No villas found.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final villa = state.items[index];
        return Card(
          child: ListTile(
            onTap: () => _openEditForm(villa),
            title: Text(villa.title),
            subtitle: Text(
              '${villa.category?.name ?? 'No category'} • ${AppFormatters.currency(villa.price)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(villa.status),
                const SizedBox(height: 4),
                const Icon(Icons.edit_outlined, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VillaFormScreen()),
    );

    if (result == true && mounted) {
      ref.read(villaProvider.notifier).load(
            search: _searchController.text.trim(),
          );
    }
  }

  Future<void> _openEditForm(Villa villa) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VillaFormScreen(villa: villa)),
    );

    if (result == true && mounted) {
      ref.read(villaProvider.notifier).load(
            search: _searchController.text.trim(),
          );
    }
  }
}
