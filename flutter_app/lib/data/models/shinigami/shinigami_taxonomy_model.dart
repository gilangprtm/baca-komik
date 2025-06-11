/// Taxonomy item model for Shinigami API (Artist, Author, Format, Genre, Type)
class ShinigamiTaxonomyItem {
  final String name;
  final String slug;

  ShinigamiTaxonomyItem({
    required this.name,
    required this.slug,
  });

  factory ShinigamiTaxonomyItem.fromJson(Map<String, dynamic> json) {
    return ShinigamiTaxonomyItem(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
    };
  }
}

/// Taxonomy model containing all taxonomy categories
class ShinigamiTaxonomy {
  final List<ShinigamiTaxonomyItem> artist;
  final List<ShinigamiTaxonomyItem> author;
  final List<ShinigamiTaxonomyItem> format;
  final List<ShinigamiTaxonomyItem> genre;
  final List<ShinigamiTaxonomyItem> type;

  ShinigamiTaxonomy({
    required this.artist,
    required this.author,
    required this.format,
    required this.genre,
    required this.type,
  });

  factory ShinigamiTaxonomy.fromJson(Map<String, dynamic> json) {
    return ShinigamiTaxonomy(
      artist: _parseList(json['Artist']),
      author: _parseList(json['Author']),
      format: _parseList(json['Format']),
      genre: _parseList(json['Genre']),
      type: _parseList(json['Type']),
    );
  }

  static List<ShinigamiTaxonomyItem> _parseList(dynamic list) {
    if (list == null) return [];
    return (list as List<dynamic>)
        .map((item) => ShinigamiTaxonomyItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'Artist': artist.map((item) => item.toJson()).toList(),
      'Author': author.map((item) => item.toJson()).toList(),
      'Format': format.map((item) => item.toJson()).toList(),
      'Genre': genre.map((item) => item.toJson()).toList(),
      'Type': type.map((item) => item.toJson()).toList(),
    };
  }

  // Helper getters for easier access
  List<String> get artistNames => artist.map((item) => item.name).toList();
  List<String> get authorNames => author.map((item) => item.name).toList();
  List<String> get formatNames => format.map((item) => item.name).toList();
  List<String> get genreNames => genre.map((item) => item.name).toList();
  List<String> get typeNames => type.map((item) => item.name).toList();

  // Get first items for display
  String? get firstArtist => artist.isNotEmpty ? artist.first.name : null;
  String? get firstAuthor => author.isNotEmpty ? author.first.name : null;
  String? get firstFormat => format.isNotEmpty ? format.first.name : null;
  String? get firstGenre => genre.isNotEmpty ? genre.first.name : null;
  String? get firstType => type.isNotEmpty ? type.first.name : null;

  // Join names for display
  String get artistsJoined => artistNames.join(', ');
  String get authorsJoined => authorNames.join(', ');
  String get formatsJoined => formatNames.join(', ');
  String get genresJoined => genreNames.join(', ');
  String get typesJoined => typeNames.join(', ');
}

/// Simple format model for format list endpoint
class ShinigamiFormat {
  final String slug;
  final String name;

  ShinigamiFormat({
    required this.slug,
    required this.name,
  });

  factory ShinigamiFormat.fromJson(Map<String, dynamic> json) {
    return ShinigamiFormat(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
    };
  }
}

/// Simple genre model for genre list endpoint
class ShinigamiGenre {
  final String slug;
  final String name;

  ShinigamiGenre({
    required this.slug,
    required this.name,
  });

  factory ShinigamiGenre.fromJson(Map<String, dynamic> json) {
    return ShinigamiGenre(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
    };
  }
}
