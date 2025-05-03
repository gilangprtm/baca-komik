import '../../../../core/base/base_network.dart';
import '../repository/vote_repository.dart';
import '../../../models/vote_model.dart';

class VoteService extends BaseService {
  final VoteRepository _voteRepository = VoteRepository();
  
  /// Add vote to comic or chapter
  Future<VoteResponse> addVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'addVote',
      function: () => _voteRepository.addVote(id, type),
    );
  }
  
  /// Remove vote from comic or chapter
  Future<VoteResponse> removeVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'removeVote',
      function: () => _voteRepository.removeVote(id, type),
    );
  }
  
  /// Toggle vote status
  Future<bool> toggleVote(String id, String type) async {
    return await performanceAsync(
      operationName: 'toggleVote',
      function: () async {
        try {
          // This is a simplified implementation
          // In a real app, you would check if the user has already voted
          // and then either add or remove the vote
          
          // For now, we'll just add a vote and assume it works
          // In a real implementation, you would need to track the vote status
          final response = await _voteRepository.addVote(id, type);
          return response.success;
        } catch (e) {
          // If adding vote fails, try removing it (assuming it exists)
          try {
            await _voteRepository.removeVote(id, type);
            return false; // Vote removed
          } catch (e) {
            logger.e('Error toggling vote', error: e, tag: 'VoteService');
            return false;
          }
        }
      },
    );
  }
}
