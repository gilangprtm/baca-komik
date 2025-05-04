import 'chapter_model.dart';

class AdjacentChapters {
  final Chapter? next;
  final Chapter? previous;

  AdjacentChapters({
    this.next,
    this.previous,
  });

  // Factory constructor from map
  factory AdjacentChapters.fromJson(Map<String, dynamic> json) {
    return AdjacentChapters(
      next: json['next'] != null ? Chapter.fromJson(json['next']) : null,
      previous:
          json['previous'] != null ? Chapter.fromJson(json['previous']) : null,
    );
  }

  // Create an empty instance
  factory AdjacentChapters.empty() {
    return AdjacentChapters(
      next: null,
      previous: null,
    );
  }
}
