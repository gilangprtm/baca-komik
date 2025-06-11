import 'package:flutter/foundation.dart';
import '../../../data/models/shinigami/shinigami_models.dart';

enum HomeStatus { initial, loading, success, error }

@immutable
class HomeState {
  final HomeStatus status;
  final List<ShinigamiManga> comics;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const HomeState({
    this.status = HomeStatus.initial,
    this.comics = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<ShinigamiManga>? comics,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
  }) {
    return HomeState(
      status: status ?? this.status,
      comics: comics ?? this.comics,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
