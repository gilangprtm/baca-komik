import '../../../../core/base/base_network.dart';
import '../../../models/user_model.dart';

class UserRepository extends BaseRepository {
  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return {
        'token': response.data['token'],
        'user': response.data['user'] != null
            ? User.fromJson(response.data['user'])
            : null,
      };
    } catch (e, stackTrace) {
      logError(
        'Error during login',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Logout current user
  Future<bool> logout() async {
    try {
      await dioService.post('/auth/logout');
      return true;
    } catch (e, stackTrace) {
      logError(
        'Error during logout',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get user profile
  Future<User> getUserProfile() async {
    try {
      final response = await dioService.get('/user/profile');
      return User.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching user profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await dioService.patch(
        '/user/profile',
        data: data,
      );

      return User.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error updating user profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
