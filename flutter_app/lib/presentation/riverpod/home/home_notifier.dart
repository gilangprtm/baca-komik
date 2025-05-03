
import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/comic_service.dart';
import 'home_state.dart';

/// StateNotifier for the home Screen
class HomeNotifier extends BaseStateNotifier<HomeState> {
  final ComicService _comicService = ComicService();
  final int _itemsPerPage = 20;
  
  HomeNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    fetchComics();
  }

  /// Fetch comics with latest chapters for the home page
  Future<void> fetchComics() async {
    if (state.isLoading) return;
    
    try {
      state = state.copyWith(
        status: HomeStatus.loading,
        isLoading: true,
        errorMessage: null,
      );
      
      // Use the new service method that returns properly typed HomeComic objects
      final homeComics = await _comicService.getHomeComics(limit: _itemsPerPage);
      
      state = state.copyWith(
        status: HomeStatus.success,
        comics: homeComics,
        isLoading: false,
        currentPage: 1,
        hasReachedMax: homeComics.length < _itemsPerPage,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching comics', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Failed to load comics: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Refresh comics data (pull-to-refresh)
  Future<void> refreshComics() async {
    state = state.copyWith(
      currentPage: 1,
      hasReachedMax: false,
    );
    await fetchComics();
  }

  /// Load more comics (pagination)
  Future<void> loadMoreComics() async {
    if (state.isLoadingMore || state.hasReachedMax) return;
    
    try {
      state = state.copyWith(
        isLoadingMore: true,
        errorMessage: null,
      );
      
      final nextPage = state.currentPage + 1;
      
      // Use the new service method that returns properly typed HomeComic objects
      // We'll need to enhance the service to support pagination
      final moreComics = await _comicService.getHomeComics(limit: _itemsPerPage);
      
      // For now, we'll just assume a simple pagination model
      // In a real implementation, we would pass the page number to getHomeComics
      final hasReachedMax = moreComics.length < _itemsPerPage;
      
      state = state.copyWith(
        comics: [...state.comics, ...moreComics],
        isLoadingMore: false,
        currentPage: nextPage,
        hasReachedMax: hasReachedMax,
      );
    } catch (e, stackTrace) {
      logger.e('Error loading more comics', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to load more comics: ${e.toString()}',
        isLoadingMore: false,
      );
    }
  }
}
