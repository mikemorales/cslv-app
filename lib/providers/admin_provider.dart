library;

import 'package:flutter_riverpod/legacy.dart';

import '../config/api_config.dart';
import '../constants/app_constants.dart';
import '../models/administrator.dart';
import '../services/administrator_service.dart';
import '../utils/cache_store.dart';

class AdminState {
  final bool isLoading;
  final String? errorMessage;
  final List<Administrator> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final String search;

  const AdminState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.search = '',
  });

  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Administrator>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    String? search,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      search: search ?? this.search,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  Future<void> load({int page = 1, String? search}) async {
    final searchTerm = search ?? state.search;
    state = state.copyWith(isLoading: true, search: searchTerm, clearError: true);

    if (page == 1 && state.items.isEmpty && searchTerm.isEmpty) {
      final cached = await CacheStore.read(AppConstants.cacheKeyAdministrators);
      if (cached != null) {
        final response = PaginatedAdministrators.fromJson(cached);
        state = state.copyWith(
          items: response.data,
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          total: response.meta.total,
        );
      }
    }

    try {
      final response = await administratorService.getAdministrators(
        page: page,
        perPage: ApiConfig.defaultPerPage,
        search: searchTerm,
      );

      if (page == 1 && searchTerm.isEmpty) {
        await CacheStore.write(
          AppConstants.cacheKeyAdministrators,
          response.toJson(),
        );
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

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>(
  (ref) => AdminNotifier(),
);
