import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'home_state.dart';
import 'home_notifier.dart';

/// Main home provider
final homeProvider = StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(const HomeState(), ref),
);

/// Provider for home comics list
final homeComicsProvider = Provider.autoDispose<List<ShinigamiManga>>((ref) {
  return ref.watch(homeProvider.select((state) => state.comics));
});

/// Provider for home loading state
final homeLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(homeProvider.select((state) => state.isLoading));
});

/// Provider for home status
final homeStatusProvider = Provider.autoDispose<HomeStatus>((ref) {
  return ref.watch(homeProvider.select((state) => state.status));
});

/// Provider for home error message
final homeErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(homeProvider.select((state) => state.errorMessage));
});

/// Provider for home pagination info
final homePaginationProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(homeProvider);
  return {
    'current_page': state.currentPage,
    'total_pages': state.totalPages,
    'has_reached_max': state.hasReachedMax,
    'is_loading_more': state.isLoadingMore,
  };
});

/// Provider for home data availability
final homeDataAvailableProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(homeProvider.select((state) => state.comics.isNotEmpty));
});
