import 'package:flutter/foundation.dart';

@immutable
class MainState {
  final int selectedIndex;

  const MainState({
    this.selectedIndex = 0,
  });

  MainState copyWith({
    int? selectedIndex,
  }) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
