import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/vote_service.dart';
import 'vote_state.dart';

class VoteNotifier extends BaseStateNotifier<VoteState> {
  final VoteService _voteService = VoteService();
  
  VoteNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state
  }

  /// Toggle vote for a comic
  Future<void> toggleComicVote(String comicId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Toggle vote through service
      final success = await _voteService.toggleVote(comicId, 'comic');
      
      // Update local state
      final updatedComicVotes = Map<String, bool>.from(state.comicVotes);
      updatedComicVotes[comicId] = success;
      
      state = state.copyWith(
        status: VoteStateStatus.success,
        comicVotes: updatedComicVotes,
        isVoting: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error toggling comic vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }

  /// Toggle vote for a chapter
  Future<void> toggleChapterVote(String chapterId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Toggle vote through service
      final success = await _voteService.toggleVote(chapterId, 'chapter');
      
      // Update local state
      final updatedChapterVotes = Map<String, bool>.from(state.chapterVotes);
      updatedChapterVotes[chapterId] = success;
      
      state = state.copyWith(
        status: VoteStateStatus.success,
        chapterVotes: updatedChapterVotes,
        isVoting: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error toggling chapter vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }

  /// Add vote to a comic
  Future<void> addComicVote(String comicId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Add vote through service
      final response = await _voteService.addVote(comicId, 'comic');
      
      if (response.success) {
        // Update local state
        final updatedComicVotes = Map<String, bool>.from(state.comicVotes);
        updatedComicVotes[comicId] = true;
        
        state = state.copyWith(
          status: VoteStateStatus.success,
          comicVotes: updatedComicVotes,
          isVoting: false,
        );
      } else {
        state = state.copyWith(
          status: VoteStateStatus.error,
          errorMessage: 'Failed to add vote',
          isVoting: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error adding comic vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }

  /// Remove vote from a comic
  Future<void> removeComicVote(String comicId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Remove vote through service
      final response = await _voteService.removeVote(comicId, 'comic');
      
      if (response.success) {
        // Update local state
        final updatedComicVotes = Map<String, bool>.from(state.comicVotes);
        updatedComicVotes[comicId] = false;
        
        state = state.copyWith(
          status: VoteStateStatus.success,
          comicVotes: updatedComicVotes,
          isVoting: false,
        );
      } else {
        state = state.copyWith(
          status: VoteStateStatus.error,
          errorMessage: 'Failed to remove vote',
          isVoting: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error removing comic vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to remove vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }

  /// Add vote to a chapter
  Future<void> addChapterVote(String chapterId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Add vote through service
      final response = await _voteService.addVote(chapterId, 'chapter');
      
      if (response.success) {
        // Update local state
        final updatedChapterVotes = Map<String, bool>.from(state.chapterVotes);
        updatedChapterVotes[chapterId] = true;
        
        state = state.copyWith(
          status: VoteStateStatus.success,
          chapterVotes: updatedChapterVotes,
          isVoting: false,
        );
      } else {
        state = state.copyWith(
          status: VoteStateStatus.error,
          errorMessage: 'Failed to add vote',
          isVoting: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error adding chapter vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }

  /// Remove vote from a chapter
  Future<void> removeChapterVote(String chapterId) async {
    try {
      state = state.copyWith(isVoting: true);
      
      // Remove vote through service
      final response = await _voteService.removeVote(chapterId, 'chapter');
      
      if (response.success) {
        // Update local state
        final updatedChapterVotes = Map<String, bool>.from(state.chapterVotes);
        updatedChapterVotes[chapterId] = false;
        
        state = state.copyWith(
          status: VoteStateStatus.success,
          chapterVotes: updatedChapterVotes,
          isVoting: false,
        );
      } else {
        state = state.copyWith(
          status: VoteStateStatus.error,
          errorMessage: 'Failed to remove vote',
          isVoting: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error removing chapter vote', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: VoteStateStatus.error,
        errorMessage: 'Failed to remove vote: ${e.toString()}',
        isVoting: false,
      );
    }
  }
}
