import '../../domain/entities/book.dart';

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

/*
 * Book Data Flow & Lifecycle:
 * 
 * 1. Incoming Data (Read / Fetch / GET)
 *    - JSON -> Model: BookModel.fromJson(json) parses the raw network/database response into a model.
 *    - Model -> Entity: model.toEntity() converts that model into a pure Book entity so your domain layer and UI can use it cleanly.
 * 
 * 2. Outgoing Data (Write / Update / POST / PUT)
 *    - Entity -> Model: BookModel.fromEntity(book) takes your pure domain entity from the UI/Use Case and wraps it into a BookModel.
 *    - Model -> JSON: model.toJson() serializes that model into a key-value map so it can be sent off to your API.
 */