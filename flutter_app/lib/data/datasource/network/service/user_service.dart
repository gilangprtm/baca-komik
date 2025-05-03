import '../../../../core/base/base_network.dart';
import '../repository/user_repository.dart';
import '../../../models/user_model.dart';

class UserService extends BaseService {
  final UserRepository _userRepository = UserRepository();
  
  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await performanceAsync(
      operationName: 'login',
      function: () => _userRepository.login(email, password),
    );
  }
  
  /// Logout current user
  Future<bool> logout() async {
    return await performanceAsync(
      operationName: 'logout',
      function: () => _userRepository.logout(),
    );
  }
  
  /// Get user profile
  Future<User> getUserProfile() async {
    return await performanceAsync(
      operationName: 'getUserProfile',
      function: () => _userRepository.getUserProfile(),
    );
  }
  
  /// Update user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    return await performanceAsync(
      operationName: 'updateUserProfile',
      function: () => _userRepository.updateUserProfile(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      ),
    );
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await performanceAsync(
      operationName: 'isAuthenticated',
      function: () async {
        try {
          // Try to get user profile, if it succeeds, user is authenticated
          await _userRepository.getUserProfile();
          return true;
        } catch (e) {
          // If it fails, user is not authenticated
          return false;
        }
      },
    );
  }
  
  /// Store authentication token
  Future<void> storeAuthToken(String token) async {
    await performanceAsync(
      operationName: 'storeAuthToken',
      function: () async {
        // Implementation would depend on your secure storage mechanism
        // For now, we'll just log it
        logger.i('Storing auth token', tag: 'UserService');
        // In a real app, you would store the token securely
        // await secureStorage.write(key: 'auth_token', value: token);
        return;
      },
    );
  }
  
  /// Clear authentication token
  Future<void> clearAuthToken() async {
    await performanceAsync(
      operationName: 'clearAuthToken',
      function: () async {
        // Implementation would depend on your secure storage mechanism
        // For now, we'll just log it
        logger.i('Clearing auth token', tag: 'UserService');
        // In a real app, you would clear the token from secure storage
        // await secureStorage.delete(key: 'auth_token');
        return;
      },
    );
  }
}
