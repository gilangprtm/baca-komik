import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/shinigami_services.dart';
import 'home_state.dart';

/// StateNotifier for the home Screen
class HomeNotifier extends BaseStateNotifier<HomeState> {
  final ShinigamiMangaService _mangaService = ShinigamiMangaService();
  final int _itemsPerPage = 10;

  HomeNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    fetchComics();
  }

  /// Fetch comics with latest chapters for the home page
  Future<void> fetchComics() async {
    if (state.isLoading) return;

    runAsync('fetchComics', () async {
      state = state.copyWith(
        status: HomeStatus.loading,
        isLoading: true,
        errorMessage: null,
      );

      try {
        // Use Shinigami API to get latest updated manga
        final response = await _mangaService.getLatestUpdatedManga(
          page: 1,
          pageSize: _itemsPerPage,
        );

        state = state.copyWith(
          status: HomeStatus.success,
          comics: response.data,
          isLoading: false,
          currentPage: 1,
          totalPages: response.meta.lastPage,
          hasReachedMax: !response.meta.hasMore,
        );
      } catch (e, stackTrace) {
        logger.e('Error fetching comics', error: e, stackTrace: stackTrace);
        state = state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load comics: ${e.toString()}',
          isLoading: false,
        );
      }
    });
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

    runAsync('loadMoreComics', () async {
      state = state.copyWith(
        isLoadingMore: true,
        errorMessage: null,
      );

      try {
        final nextPage = state.currentPage + 1;

        // Use Shinigami API to get more latest updated manga
        final response = await _mangaService.getLatestUpdatedManga(
          page: nextPage,
          pageSize: _itemsPerPage,
        );

        state = state.copyWith(
          comics: [...state.comics, ...response.data],
          isLoadingMore: false,
          currentPage: nextPage,
          totalPages: response.meta.lastPage,
          hasReachedMax: !response.meta.hasMore,
        );
      } catch (e, stackTrace) {
        logger.e('Error loading more comics', error: e, stackTrace: stackTrace);
        state = state.copyWith(
          errorMessage: 'Failed to load more comics: ${e.toString()}',
          isLoadingMore: false,
        );
      }
    });
  }
}
