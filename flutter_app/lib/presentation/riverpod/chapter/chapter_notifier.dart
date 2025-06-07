import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/chapter_service.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/page_model.dart';
import 'chapter_state.dart';

class ChapterNotifier extends BaseStateNotifier<ChapterState> {
  final ChapterService _chapterService = ChapterService();

  // Store initial state for easy reset
  static final ChapterState _initialState = ChapterState();

  ChapterNotifier(super.initialState, super.ref);

  /// Reset state to initial state (useful for clearing navigation data)
  void _resetToInitialState() {
    state = _initialState.copyWith(
      status: ChapterStateStatus.loading,
    );
  }

  @override
  void onInit() {
    super.onInit();

    // Get chapterId from route arguments
    final chapterId = Mahas.argument<String>('chapterId');

    // Fetch chapter details if chapterId is available
    if (chapterId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchChapterDetails(chapterId);
      });
    }
  }

  /// Fetch chapter details by ID (optimized)
  Future<void> fetchChapterDetails(String chapterId) async {
    runAsync('fetchChapterDetails', () async {
      // Reset to initial state to clear all previous data
      _resetToInitialState();

      // Fetch chapter details and pages in parallel for better performance
      final results = await Future.wait([
        _chapterService.getChapterDetails(chapterId),
        _chapterService.getChapterPages(chapterId),
      ]);

      final chapter = results[0] as Chapter;
      final chapterPages = results[1] as ChapterPages;

      // Update state with new chapter data
      state = state.copyWith(
        status: ChapterStateStatus.success,
        chapter: chapter,
        pages: chapterPages.pages,
        currentPageIndex: 0,
        nextChapter: chapter.nextChapter,
        previousChapter: chapter.prevChapter,
      );
    });
  }

  /// Toggle reader controls visibility
  void toggleReaderControls() {
    run('toggleReaderControls', () {
      state = state.copyWith(
        isReaderControlsVisible: !state.isReaderControlsVisible,
      );
    });
  }

  /// Navigate to next chapter
  Future<void> nextChapter() async {
    runAsync('nextChapter', () async {
      if (state.nextChapter != null) {
        await fetchChapterDetails(state.nextChapter!.id);
      }
    });
  }

  /// Navigate to previous chapter
  Future<void> previousChapter() async {
    runAsync('previousChapter', () async {
      if (state.previousChapter != null) {
        await fetchChapterDetails(state.previousChapter!.id);
      }
    });
  }

  /// Navigate to specific chapter by ID
  Future<void> goToChapter(String chapterId) async {
    runAsync('goToChapter', () async {
      await fetchChapterDetails(chapterId);
    });
  }
}
