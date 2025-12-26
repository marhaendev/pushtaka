import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.stock,
    super.image,
    required super.slug,
    super.year,
    super.code,
    super.isbn,
    super.publisher,
    super.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString(),
      slug: json['slug']?.toString() ?? '',
      year: int.tryParse(json['publication_year']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
