import 'package:flutter/foundation.dart';
import '../../../data/models/complete_chapter_model.dart';

enum ChapterStateStatus { initial, loading, success, error }

@immutable
class ChapterState {
  final ChapterStateStatus status;
  final CompleteChapter? currentChapter;
  final String? errorMessage;
  final int currentPageIndex;
  final bool isReaderControlsVisible;
  final double zoomLevel;
  final bool isHorizontalReading;

  const ChapterState({
    this.status = ChapterStateStatus.initial,
    this.currentChapter,
    this.errorMessage,
    this.currentPageIndex = 0,
    this.isReaderControlsVisible = true,
    this.zoomLevel = 1.0,
    this.isHorizontalReading = true,
  });

  ChapterState copyWith({
    ChapterStateStatus? status,
    CompleteChapter? currentChapter,
    String? errorMessage,
    int? currentPageIndex,
    bool? isReaderControlsVisible,
    double? zoomLevel,
    bool? isHorizontalReading,
  }) {
    return ChapterState(
      status: status ?? this.status,
      currentChapter: currentChapter ?? this.currentChapter,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isReaderControlsVisible: isReaderControlsVisible ?? this.isReaderControlsVisible,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isHorizontalReading: isHorizontalReading ?? this.isHorizontalReading,
    );
  }

  // Helper methods for reader
  bool get isFirstPage => currentPageIndex == 0;
  
  bool get isLastPage {
    if (currentChapter == null || currentChapter!.pages.isEmpty) return true;
    return currentPageIndex >= currentChapter!.pages.length - 1;
  }
  
  int get totalPages => currentChapter?.pages.length ?? 0;
  
  String? get nextChapterId => currentChapter?.navigation.nextChapter?.id;
  
  String? get prevChapterId => currentChapter?.navigation.prevChapter?.id;
}
