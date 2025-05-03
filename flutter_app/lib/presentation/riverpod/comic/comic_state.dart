import 'package:flutter/foundation.dart';
import '../../../data/models/home_comic_model.dart';
import '../../../data/models/discover_comic_model.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../../data/models/metadata_models.dart';

enum ComicStateStatus { initial, loading, success, error }

@immutable
class ComicState {
  final ComicStateStatus homeStatus;
  final ComicStateStatus discoverStatus;
  final ComicStateStatus detailStatus;
  final List<HomeComic> homeComics;
  final List<DiscoverComic> discoverComics;
  final CompleteComic? selectedComic;
  final MetaData? homeMeta;
  final MetaData? discoverMeta;
  final String? errorMessage;
  final bool hasMoreHomeComics;
  final bool hasMoreDiscoverComics;
  final String? searchQuery;
  final String? selectedGenre;
  final String? selectedFormat;
  final String? selectedCountry;

  const ComicState({
    this.homeStatus = ComicStateStatus.initial,
    this.discoverStatus = ComicStateStatus.initial,
    this.detailStatus = ComicStateStatus.initial,
    this.homeComics = const [],
    this.discoverComics = const [],
    this.selectedComic,
    this.homeMeta,
    this.discoverMeta,
    this.errorMessage,
    this.hasMoreHomeComics = true,
    this.hasMoreDiscoverComics = true,
    this.searchQuery,
    this.selectedGenre,
    this.selectedFormat,
    this.selectedCountry,
  });

  ComicState copyWith({
    ComicStateStatus? homeStatus,
    ComicStateStatus? discoverStatus,
    ComicStateStatus? detailStatus,
    List<HomeComic>? homeComics,
    List<DiscoverComic>? discoverComics,
    CompleteComic? selectedComic,
    MetaData? homeMeta,
    MetaData? discoverMeta,
    String? errorMessage,
    bool? hasMoreHomeComics,
    bool? hasMoreDiscoverComics,
    String? searchQuery,
    String? selectedGenre,
    String? selectedFormat,
    String? selectedCountry,
  }) {
    return ComicState(
      homeStatus: homeStatus ?? this.homeStatus,
      discoverStatus: discoverStatus ?? this.discoverStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      homeComics: homeComics ?? this.homeComics,
      discoverComics: discoverComics ?? this.discoverComics,
      selectedComic: selectedComic ?? this.selectedComic,
      homeMeta: homeMeta ?? this.homeMeta,
      discoverMeta: discoverMeta ?? this.discoverMeta,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMoreHomeComics: hasMoreHomeComics ?? this.hasMoreHomeComics,
      hasMoreDiscoverComics: hasMoreDiscoverComics ?? this.hasMoreDiscoverComics,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}
