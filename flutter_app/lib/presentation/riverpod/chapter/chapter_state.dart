import 'package:flutter/foundation.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/page_model.dart';

enum ChapterStateStatus { initial, loading, success, error }

@immutable
class ChapterState {
  final ChapterStateStatus status;
  final Chapter? chapter;
  final List<Page> pages;
  final Chapter? nextChapter;
  final Chapter? previousChapter;
  final String? errorMessage;
  final int currentPageIndex;
  final bool isReaderControlsVisible;
  final double zoomLevel;
  final bool isHorizontalReading;

  const ChapterState({
    this.status = ChapterStateStatus.initial,
    this.chapter,
    this.pages = const [],
    this.nextChapter,
    this.previousChapter,
    this.errorMessage,
    this.currentPageIndex = 0,
    this.isReaderControlsVisible = true,
    this.zoomLevel = 1.0,
    this.isHorizontalReading = true,
  });

  ChapterState copyWith({
    ChapterStateStatus? status,
    Chapter? chapter,
    List<Page>? pages,
    Chapter? nextChapter,
    Chapter? previousChapter,
    String? errorMessage,
    int? currentPageIndex,
    bool? isReaderControlsVisible,
    double? zoomLevel,
    bool? isHorizontalReading,
  }) {
    return ChapterState(
      status: status ?? this.status,
      chapter: chapter ?? this.chapter,
      pages: pages ?? this.pages,
      nextChapter: nextChapter ?? this.nextChapter,
      previousChapter: previousChapter ?? this.previousChapter,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isReaderControlsVisible:
          isReaderControlsVisible ?? this.isReaderControlsVisible,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isHorizontalReading: isHorizontalReading ?? this.isHorizontalReading,
    );
  }

  // Helper methods for reader
  bool get isFirstPage => currentPageIndex == 0;

  bool get isLastPage {
    if (pages.isEmpty) return true;
    return currentPageIndex >= pages.length - 1;
  }

  int get totalPages => pages.length;
}
