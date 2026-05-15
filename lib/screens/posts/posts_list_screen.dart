import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/state_views.dart';
import 'post_form_screen.dart';

class PostsListScreen extends ConsumerStatefulWidget {
  const PostsListScreen({super.key});

  @override
  ConsumerState<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends ConsumerState<PostsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search posts',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        ref.read(postProvider.notifier).load(
                              search: value.trim(),
                              status: state.status,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: state.status,
                    items: AppConstants.postStatuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      ref.read(postProvider.notifier).load(
                            search: _searchController.text.trim(),
                            status: value,
                          );
                    },
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openCreateForm,
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(state)),
      ],
    );
  }

  Widget _buildContent(PostState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const ListSkeletonView();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(postProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyView(message: 'No posts found.');
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final post = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => _openEditForm(post),
                  title: Text(post.title),
                  subtitle: Text(post.slug),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(post.status),
                      const SizedBox(height: 4),
                      const Icon(Icons.edit_outlined, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        PaginationBar(
          currentPage: state.currentPage,
          lastPage: state.lastPage,
          total: state.total,
          onPageChanged: (page) {
            ref.read(postProvider.notifier).load(
                  page: page,
                  search: _searchController.text.trim(),
                  status: state.status,
                );
          },
        ),
      ],
    );
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );

    if (result == true && mounted) {
      ref.read(postProvider.notifier).load(
            search: _searchController.text.trim(),
            status: ref.read(postProvider).status,
          );
      AppFeedback.success(context, 'Post created successfully.');
    }
  }

  Future<void> _openEditForm(Post post) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PostFormScreen(post: post)),
    );

    if (result == true && mounted) {
      ref.read(postProvider.notifier).load(
            search: _searchController.text.trim(),
            status: ref.read(postProvider).status,
          );
      AppFeedback.success(context, 'Post updated successfully.');
    }
  }
}
