class OpenLibraryResponse {
  final List<OpenLibraryDoc>? docs;

  OpenLibraryResponse({this.docs});

  factory OpenLibraryResponse.fromJson(Map<String, dynamic> json) {
    return OpenLibraryResponse(
      docs:
          (json['docs'] as List?)
              ?.map((e) => OpenLibraryDoc.fromJson(e))
              .toList(),
    );
  }
}

class OpenLibraryDoc {
  final String key;
  final String title;
  final List<String>? authorName;
  final int? firstPublishYear;
  final List<String>? isbn;
  final List<String>? publisher;
  final int? coverI;

  OpenLibraryDoc({
    required this.key,
    required this.title,
    this.authorName,
    this.firstPublishYear,
    this.isbn,
    this.publisher,
    this.coverI,
  });

  factory OpenLibraryDoc.fromJson(Map<String, dynamic> json) {
    return OpenLibraryDoc(
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      authorName:
          (json['author_name'] as List?)?.map((e) => e.toString()).toList(),
      firstPublishYear: json['first_publish_year'],
      isbn: (json['isbn'] as List?)?.map((e) => e.toString()).toList(),
      publisher:
          (json['publisher'] as List?)?.map((e) => e.toString()).toList(),
      coverI: json['cover_i'],
    );
  }

  String? get coverUrl {
    if (coverI != null) {
      return "https://covers.openlibrary.org/b/id/$coverI-L.jpg";
    }
    if (isbn != null && isbn!.isNotEmpty) {
      return "https://covers.openlibrary.org/b/isbn/${isbn!.first}-L.jpg";
    }
    return null;
  }
}
