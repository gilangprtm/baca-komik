
import '../../../core/base/base_state_notifier.dart';
import 'home_state.dart';

/// StateNotifier for the home Screen
class HomeNotifier extends BaseStateNotifier<HomeState> {
  HomeNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Your initialization logic here
  }

  @override
  void onReady() {
    super.onReady();
    // Your ready logic here
  }

  /// Example method to update the state
  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1);
  }
}
