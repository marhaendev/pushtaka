import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final int id;
  final String title;
  final String author;
  final int stock;
  final String? image;
  final String slug;
  final int year;
  final String code;
  final String isbn;
  final String publisher;
  final String description;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.stock,
    this.image,
    required this.slug,
    this.year = 0,
    this.code = '',
    this.isbn = '',
    this.publisher = '',
    this.description = '',
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    stock,
    image,
    slug,
    year,
    code,
    isbn,
    publisher,
    description,
  ];
}
