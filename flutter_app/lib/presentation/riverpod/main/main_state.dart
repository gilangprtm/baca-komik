import 'package:flutter/foundation.dart';

import '../../../data/models/firebase/must_update_model.dart';

@immutable
class MainState {
  final int selectedIndex;
  final MustUpdateModel? mustUpdate;

  const MainState({
    this.selectedIndex = 0,
    this.mustUpdate,
  });

  MainState copyWith({
    int? selectedIndex,
    MustUpdateModel? mustUpdate,
  }) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      mustUpdate: mustUpdate ?? this.mustUpdate,
    );
  }
}
