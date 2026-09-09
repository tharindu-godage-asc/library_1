import '../../domain/entities/book.dart';

/// Knows how to read the API's JSON shape and map it to a domain [Book].
/// If the backend renames a field or nests something differently, this
/// is the only file that changes — the Book entity and everything that
/// consumes it stay untouched.
class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.isbn,
    required super.publishedYear,
    required super.totalCopies,
    required super.availableCopies,
    super.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      publishedYear: json['publishedYear'] as int,
      totalCopies: json['totalCopies'] as int,
      availableCopies: json['availableCopies'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'isbn': isbn,
        'publishedYear': publishedYear,
        'totalCopies': totalCopies,
        'availableCopies': availableCopies,
        'description': description,
      };

  Book toEntity() => Book(
        id: id,
        title: title,
        author: author,
        isbn: isbn,
        publishedYear: publishedYear,
        totalCopies: totalCopies,
        availableCopies: availableCopies,
        description: description,
      );

    factory BookModel.fromEntity(Book book) => BookModel(
        id: book.id, title: book.title, author: book.author, isbn: book.isbn,
        publishedYear: book.publishedYear, totalCopies: book.totalCopies,
        availableCopies: book.availableCopies, description: book.description,
      );
}