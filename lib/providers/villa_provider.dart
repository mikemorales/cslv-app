library;

import 'package:flutter_riverpod/legacy.dart';

import '../config/api_config.dart';
import '../models/villa.dart';
import '../constants/app_constants.dart';
import '../services/villa_service.dart';
import '../utils/cache_store.dart';

class VillaState {
  final bool isLoading;
  final String? errorMessage;
  final List<Villa> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final String search;

  const VillaState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.search = '',
  });

  VillaState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Villa>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    String? search,
  }) {
    return VillaState(
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

class VillaNotifier extends StateNotifier<VillaState> {
  VillaNotifier() : super(const VillaState());

  Future<void> load({int page = 1, String? search}) async {
    final searchTerm = search ?? state.search;
    state = state.copyWith(isLoading: true, search: searchTerm, clearError: true);

    if (page == 1 && state.items.isEmpty && searchTerm.isEmpty) {
      final cached = await CacheStore.read(AppConstants.cacheKeyVillas);
      if (cached != null) {
        final response = PaginatedVillas.fromJson(cached);
        state = state.copyWith(
          items: response.data,
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          total: response.meta.total,
        );
      }
    }

    try {
      final response = await villaService.getVillas(
        page: page,
        perPage: ApiConfig.defaultPerPage,
        search: searchTerm,
      );

      if (page == 1 && searchTerm.isEmpty) {
        await CacheStore.write(AppConstants.cacheKeyVillas, response.toJson());
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

final villaProvider = StateNotifierProvider<VillaNotifier, VillaState>(
  (ref) => VillaNotifier(),
);
