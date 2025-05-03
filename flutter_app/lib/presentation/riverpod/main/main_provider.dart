import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_state.dart';
import 'main_notifier.dart';

final mainProvider = StateNotifierProvider<MainNotifier, MainState>(
  (ref) => MainNotifier(const MainState(), ref),
);
