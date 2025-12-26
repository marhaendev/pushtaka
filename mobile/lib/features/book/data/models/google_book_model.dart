class GoogleBooksResponse {
  final List<GoogleBookItem>? items;

  GoogleBooksResponse({this.items});

  factory GoogleBooksResponse.fromJson(Map<String, dynamic> json) {
    return GoogleBooksResponse(
      items:
          (json['items'] as List?)
              ?.map((e) => GoogleBookItem.fromJson(e))
              .toList(),
    );
  }
}

class GoogleBookItem {
  final String id;
  final VolumeInfo volumeInfo;

  GoogleBookItem({required this.id, required this.volumeInfo});

  factory GoogleBookItem.fromJson(Map<String, dynamic> json) {
    return GoogleBookItem(
      id: json['id'],
      volumeInfo: VolumeInfo.fromJson(json['volumeInfo']),
    );
  }
}

class VolumeInfo {
  final String title;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final List<IndustryIdentifier>? industryIdentifiers;
  final ImageLinks? imageLinks;

  VolumeInfo({
    required this.title,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.industryIdentifiers,
    this.imageLinks,
  });

  factory VolumeInfo.fromJson(Map<String, dynamic> json) {
    return VolumeInfo(
      title: json['title'] ?? '',
      authors: (json['authors'] as List?)?.map((e) => e.toString()).toList(),
      publisher: json['publisher'],
      publishedDate: json['publishedDate'],
      description: json['description'],
      industryIdentifiers:
          (json['industryIdentifiers'] as List?)
              ?.map((e) => IndustryIdentifier.fromJson(e))
              .toList(),
      imageLinks:
          json['imageLinks'] != null
              ? ImageLinks.fromJson(json['imageLinks'])
              : null,
    );
  }
}

class IndustryIdentifier {
  final String type;
  final String identifier;

  IndustryIdentifier({required this.type, required this.identifier});

  factory IndustryIdentifier.fromJson(Map<String, dynamic> json) {
    return IndustryIdentifier(
      type: json['type'] ?? '',
      identifier: json['identifier'] ?? '',
    );
  }
}

class ImageLinks {
  final String? thumbnail;
  final String? smallThumbnail;

  ImageLinks({this.thumbnail, this.smallThumbnail});

  factory ImageLinks.fromJson(Map<String, dynamic> json) {
    return ImageLinks(
      thumbnail: json['thumbnail'],
      smallThumbnail: json['smallThumbnail'],
    );
  }
}
