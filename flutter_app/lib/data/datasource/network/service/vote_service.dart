import '../../../../core/base/base_network.dart';
import '../repository/vote_repository.dart';
import '../repository/comic_repository.dart';
import '../repository/chapter_repository.dart';
import '../../../models/vote_model.dart';

class VoteService extends BaseService {
  final VoteRepository _voteRepository = VoteRepository();
  final ComicRepository _comicRepository = ComicRepository();
  final ChapterRepository _chapterRepository = ChapterRepository();

  /// Add vote to comic or chapter with validation and error handling
  Future<VoteResponse> addVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'addVote',
      function: () async {
        try {
          // Validate inputs
          if (id.isEmpty) {
            throw Exception('ID cannot be empty');
          }

          if (type != 'comic' && type != 'chapter') {
            throw Exception('Type must be either "comic" or "chapter"');
          }

          // Verify that the entity exists before voting
          await _verifyEntityExists(id, type);

          // Check if user has already voted
          final hasVoted = await _hasUserVoted(id, type);
          if (hasVoted) {
            logger.w('User has already voted for this $type',
                tag: 'VoteService');
            throw Exception('User has already voted');
          }

          // Add the vote through repository
          final response = await _voteRepository.addVote(id, type);

          // Log the successful vote
          logger.i('Added vote for $type: $id', tag: 'VoteService');

          return response;
        } catch (e, stackTrace) {
          logger.e('Error adding vote',
              error: e, stackTrace: stackTrace, tag: 'VoteService');

          // Re-throw error
          rethrow;
        }
      },
    );
  }

  /// Remove vote from comic or chapter with validation
  Future<VoteResponse> removeVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'removeVote',
      function: () async {
        try {
          // Validate inputs
          if (id.isEmpty) {
            throw Exception('ID cannot be empty');
          }

          if (type != 'comic' && type != 'chapter') {
            throw Exception('Type must be either "comic" or "chapter"');
          }

          // Check if user has voted (can't remove a non-existent vote)
          final hasVoted = await _hasUserVoted(id, type);
          if (!hasVoted) {
            logger.w('User has not voted for this $type', tag: 'VoteService');
            throw Exception('User has not voted');
          }

          // Remove the vote through repository
          final response = await _voteRepository.removeVote(id, type);

          // Log the successful vote removal
          logger.i('Removed vote for $type: $id', tag: 'VoteService');

          return response;
        } catch (e, stackTrace) {
          logger.e('Error removing vote',
              error: e, stackTrace: stackTrace, tag: 'VoteService');

          // Re-throw error
          rethrow;
        }
      },
    );
  }

  /// Toggle vote status with intelligent handling
  Future<VoteResult> toggleVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'toggleVote',
      function: () async {
        try {
          // Check if user has already voted
          final hasVoted = await _hasUserVoted(id, type);

          bool newVoteStatus;
          String resultMessage;

          if (hasVoted) {
            // User has voted, so remove the vote
            await removeVote(id, type);
            newVoteStatus = false;
            resultMessage = 'Vote removed successfully';
          } else {
            // User hasn't voted, so add a vote
            await addVote(id, type);
            newVoteStatus = true;
            resultMessage = 'Voted successfully';
          }

          // Get the updated vote count after the operation
          final int updatedVoteCount = await _getVoteCount(id, type);

          return VoteResult(
            success: true,
            message: resultMessage,
            voted: newVoteStatus,
            voteCount: updatedVoteCount,
          );
        } catch (e, stackTrace) {
          logger.e('Error toggling vote',
              error: e, stackTrace: stackTrace, tag: 'VoteService');

          return VoteResult(
            success: false,
            message: 'Failed to toggle vote: ${e.toString()}',
            voted: false,
            voteCount: 0,
          );
        }
      },
    );
  }

  /// Get vote status for a comic or chapter
  Future<bool> hasUserVoted(String id, String type) async {
    return await performanceAsync(
      operationName: 'hasUserVoted',
      function: () => _hasUserVoted(id, type),
    );
  }

  /// Get vote count for a comic or chapter
  Future<int> getVoteCount(String id, String type) async {
    return await performanceAsync(
      operationName: 'getVoteCount',
      function: () => _getVoteCount(id, type),
    );
  }

  // Helper method to check if user has voted
  Future<bool> _hasUserVoted(String id, String type) async {
    try {
      // In a real implementation, this would call an API endpoint
      // to check if the user has voted

      // For now, simulate a check using CompleteComic or CompleteChapter
      if (type == 'comic') {
        // We would use the repository to get user vote status
        // For now, return false to simulate not voted
        return false;
      } else if (type == 'chapter') {
        // We would use the repository to get user vote status
        // For now, return false to simulate not voted
        return false;
      }

      return false;
    } catch (e) {
      logger.e('Error checking vote status', error: e, tag: 'VoteService');
      return false;
    }
  }

  // Helper method to get vote count
  Future<int> _getVoteCount(String id, String type) async {
    try {
      // In a real implementation, this would get the current vote count

      if (type == 'comic') {
        // Get comic details to get vote count
        final comic = await _comicRepository.getComicDetails(id);
        return comic.voteCount;
      } else if (type == 'chapter') {
        // Get chapter details to get vote count
        final chapter = await _chapterRepository.getChapterDetails(id);
        return chapter.voteCount;
      }

      return 0;
    } catch (e) {
      logger.e('Error getting vote count', error: e, tag: 'VoteService');
      return 0;
    }
  }

  // Helper method to verify entity exists
  Future<void> _verifyEntityExists(String id, String type) async {
    try {
      if (type == 'comic') {
        // Verify comic exists
        await _comicRepository.getComicDetails(id);
      } else if (type == 'chapter') {
        // Verify chapter exists
        await _chapterRepository.getChapterDetails(id);
      }
    } catch (e) {
      throw Exception('${type.capitalize()} not found');
    }
  }
}

// Helper method to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
