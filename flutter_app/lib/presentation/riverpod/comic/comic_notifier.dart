import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/optimized_comic_service.dart';
import '../../../data/models/home_comic_model.dart';
import '../../../data/models/discover_comic_model.dart';
import '../../../data/models/metadata_models.dart';
import 'comic_state.dart';

class ComicNotifier extends BaseStateNotifier<ComicState> {
  final OptimizedComicService _comicService = OptimizedComicService();
  
  ComicNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state
  }

  @override
  void onReady() {
    super.onReady();
    // Fetch initial data when ready
    fetchHomeComics();
  }

  /// Fetch comics for home page
  Future<void> fetchHomeComics({bool refresh = false}) async {
    try {
      // If refreshing, reset to initial page, otherwise keep current state
      final page = refresh ? 1 : (state.homeMeta?.page ?? 0) + 1;
      
      // Only show loading indicator on first page or refresh
      if (page == 1) {
        state = state.copyWith(homeStatus: ComicStateStatus.loading);
      }

      // Fetch home comics from service
      final result = await _comicService.getHomeComics(
        page: page,
        limit: 10,
        sort: 'updated_date',
        order: 'desc',
      );

      // Extract data and metadata
      final List<HomeComic> comics = result['data'] as List<HomeComic>;
      final MetaData meta = result['meta'] as MetaData;
      
      // If refreshing, replace the list, otherwise append
      final updatedComics = page == 1 
          ? comics 
          : [...state.homeComics, ...comics];
      
      // Update state with new data
      state = state.copyWith(
        homeStatus: ComicStateStatus.success,
        homeComics: updatedComics,
        homeMeta: meta,
        hasMoreHomeComics: meta.hasMore,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching home comics', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        homeStatus: ComicStateStatus.error,
        errorMessage: 'Failed to load comics: ${e.toString()}',
      );
    }
  }

  /// Fetch comics for discover page with filters
  Future<void> fetchDiscoverComics({
    bool refresh = false,
    String? search,
    String? genre,
    String? format,
    String? country,
  }) async {
    try {
      // If refreshing or changing filters, reset to initial page
      final isFilterChange = search != state.searchQuery ||
          genre != state.selectedGenre ||
          format != state.selectedFormat ||
          country != state.selectedCountry;
      
      final page = (refresh || isFilterChange) ? 1 : (state.discoverMeta?.page ?? 0) + 1;
      
      // Only show loading indicator on first page, refresh, or filter change
      if (page == 1) {
        state = state.copyWith(
          discoverStatus: ComicStateStatus.loading,
          searchQuery: search,
          selectedGenre: genre,
          selectedFormat: format,
          selectedCountry: country,
        );
      }

      // Fetch discover comics from service
      final result = await _comicService.getDiscoverComics(
        page: page,
        limit: 10,
        search: search ?? state.searchQuery,
        genre: genre ?? state.selectedGenre,
        format: format ?? state.selectedFormat,
        country: country ?? state.selectedCountry,
      );

      // Extract data and metadata
      final List<DiscoverComic> comics = result['data'] as List<DiscoverComic>;
      final MetaData meta = result['meta'] as MetaData;
      
      // If refreshing or changing filters, replace the list, otherwise append
      final updatedComics = (page == 1 || isFilterChange)
          ? comics 
          : [...state.discoverComics, ...comics];
      
      // Update state with new data
      state = state.copyWith(
        discoverStatus: ComicStateStatus.success,
        discoverComics: updatedComics,
        discoverMeta: meta,
        hasMoreDiscoverComics: meta.hasMore,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching discover comics', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        discoverStatus: ComicStateStatus.error,
        errorMessage: 'Failed to load comics: ${e.toString()}',
      );
    }
  }

  /// Fetch complete comic details by ID
  Future<void> fetchComicDetails(String comicId) async {
    try {
      state = state.copyWith(detailStatus: ComicStateStatus.loading);
      
      // Fetch complete comic details from service
      final comic = await _comicService.getCompleteComicDetails(comicId);
      
      // Update state with comic details
      state = state.copyWith(
        detailStatus: ComicStateStatus.success,
        selectedComic: comic,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching comic details', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        detailStatus: ComicStateStatus.error,
        errorMessage: 'Failed to load comic details: ${e.toString()}',
      );
    }
  }
}
