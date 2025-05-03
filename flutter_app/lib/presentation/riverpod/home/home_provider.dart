
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';
import 'home_notifier.dart';

final HomeProvider = StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(const HomeState(), ref),
);
