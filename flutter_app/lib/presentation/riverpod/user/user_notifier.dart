// flutter_riverpod sudah diimpor melalui base_state_notifier.dart
import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/user_service.dart';
import '../../../data/models/user_model.dart';
import 'user_state.dart';

class UserNotifier extends BaseStateNotifier<UserState> {
  final UserService _userService = UserService();
  
  UserNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Check authentication status on initialization
    checkAuthStatus();
  }

  /// Check if user is authenticated
  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.loading,
        isLoading: true,
      );
      
      final isAuthenticated = await _userService.isAuthenticated();
      
      if (isAuthenticated) {
        // If authenticated, fetch user profile
        await getUserProfile();
      } else {
        state = state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          user: null,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error checking auth status', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: 'Authentication check failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(
        authStatus: AuthStatus.loading,
        isLoading: true,
        errorMessage: null,
      );
      
      final result = await _userService.login(email, password);
      final user = result['user'] as User?;
      
      if (user != null) {
        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          authStatus: AuthStatus.error,
          errorMessage: 'Login failed: User data not received',
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error during login', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: 'Login failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Catatan: Implementasi register tidak tersedia di UserService saat ini
  // Dapat diimplementasikan di masa depan jika diperlukan

  /// Logout current user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _userService.logout();
      
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: null,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error during logout', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Logout failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Get user profile
  Future<void> getUserProfile() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final user = await _userService.getUserProfile();
      
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching user profile', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: 'Failed to fetch profile: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isUpdating: true);
      
      final updatedUser = await _userService.updateUserProfile(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
      
      state = state.copyWith(
        user: updatedUser,
        isUpdating: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error updating user profile', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Profile update failed: ${e.toString()}',
        isUpdating: false,
      );
    }
  }

  // Catatan: Implementasi changePassword tidak tersedia di UserService saat ini
  // Dapat diimplementasikan di masa depan jika diperlukan

  // Catatan: Implementasi resetPassword tidak tersedia di UserService saat ini
  // Dapat diimplementasikan di masa depan jika diperlukan

  // Catatan: Implementasi deleteAccount tidak tersedia di UserService saat ini
  // Dapat diimplementasikan di masa depan jika diperlukan
}
