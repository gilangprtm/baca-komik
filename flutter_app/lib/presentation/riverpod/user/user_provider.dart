import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';
import 'user_notifier.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(const UserState(), ref),
);
