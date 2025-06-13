class MustUpdateModel {
  final bool mustUpdate;
  final String? linkUpdate;

  MustUpdateModel({
    required this.mustUpdate,
    this.linkUpdate,
  });

  factory MustUpdateModel.fromJson(Map<String, dynamic> json) {
    return MustUpdateModel(
      mustUpdate: json['must_update'] ?? false,
      linkUpdate: json['link_update'] ?? '',
    );
  }
}
