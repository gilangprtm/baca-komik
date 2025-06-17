class UrlInformationModel {
  final String? title;
  final String? url;

  UrlInformationModel({
    this.title,
    this.url,
  });

  factory UrlInformationModel.fromJson(Map<String, dynamic> json) {
    return UrlInformationModel(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
