import 'comic_model.dart';

class FeaturedComicsResponse {
  final List<Comic> recommended;
  final List<Comic> popular;

  FeaturedComicsResponse({
    required this.recommended,
    required this.popular,
  });

  // Create an empty response
  factory FeaturedComicsResponse.empty() {
    return FeaturedComicsResponse(
      recommended: <Comic>[],
      popular: <Comic>[],
    );
  }
}
