import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

@immutable
class UserState {
  final AuthStatus authStatus;
  final User? user;
  final String? errorMessage;
  final bool isLoading;
  final bool isUpdating;

  const UserState({
    this.authStatus = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.isUpdating = false,
  });

  UserState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool? isUpdating,
  }) {
    return UserState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  bool get isAuthenticated => authStatus == AuthStatus.authenticated;
  bool get isUnauthenticated => authStatus == AuthStatus.unauthenticated;
}
