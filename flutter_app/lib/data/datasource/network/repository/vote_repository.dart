import '../../../../core/base/base_network.dart';
import '../../../models/vote_model.dart';

class VoteRepository extends BaseRepository {
  /// Add vote to comic or chapter
  Future<VoteResponse> addVote(String id, String type) async {
    try {
      final response = await dioService.post(
        '/votes',
        data: {
          'id': id,
          'type': type, // 'comic' or 'chapter'
        },
      );

      return VoteResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error adding vote',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove vote from comic or chapter
  Future<VoteResponse> removeVote(String id, String type) async {
    try {
      final response = await dioService.delete(
        '/votes/$id',
        queryParameters: {
          'type': type, // 'comic' or 'chapter'
        },
      );

      return VoteResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error removing vote',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
