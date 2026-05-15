library;

import 'package:flutter_riverpod/legacy.dart';

import '../config/api_config.dart';
import '../constants/app_constants.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/cache_store.dart';

class PostState {
  final bool isLoading;
  final String? errorMessage;
  final List<Post> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final String search;
  final String status;

  const PostState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.search = '',
    this.status = 'published',
  });

  PostState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Post>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    String? search,
    String? status,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      search: search ?? this.search,
      status: status ?? this.status,
    );
  }
}

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(const PostState());

  Future<void> load({
    int page = 1,
    String? search,
    String? status,
  }) async {
    final searchTerm = search ?? state.search;
    final selectedStatus = status ?? state.status;

    state = state.copyWith(
      isLoading: true,
      search: searchTerm,
      status: selectedStatus,
      clearError: true,
    );

    if (page == 1 &&
        state.items.isEmpty &&
        searchTerm.isEmpty &&
        selectedStatus == 'published') {
      final cached = await CacheStore.read(AppConstants.cacheKeyPosts);
      if (cached != null) {
        final response = PaginatedPosts.fromJson(cached);
        state = state.copyWith(
          items: response.data,
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          total: response.meta.total,
        );
      }
    }

    try {
      final response = await postService.getPosts(
        page: page,
        perPage: ApiConfig.defaultPerPage,
        search: searchTerm,
        status: selectedStatus,
      );

      if (page == 1 && searchTerm.isEmpty && selectedStatus == 'published') {
        await CacheStore.write(AppConstants.cacheKeyPosts, response.toJson());
      }

      state = state.copyWith(
        isLoading: false,
        items: response.data,
        currentPage: response.meta.currentPage,
        lastPage: response.meta.lastPage,
        total: response.meta.total,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}

final postProvider = StateNotifierProvider<PostNotifier, PostState>(
  (ref) => PostNotifier(),
);
