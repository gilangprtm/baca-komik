import '../../../core/base/base_state_notifier.dart';
import '../../../core/base/global_state.dart';
import 'main_state.dart';

class MainNotifier extends BaseStateNotifier<MainState> {
  MainNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Any initialization logic can go here
    state = state.copyWith(mustUpdate: GlobalState.mustUpdate);
  }

  /// Change the selected tab index
  void changeTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}
