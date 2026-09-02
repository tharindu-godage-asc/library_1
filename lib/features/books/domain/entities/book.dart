
class Book{

    const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publishedYear,
    required this.totalCopies,
    required this.availableCopies,
    this.description,
  });

    final String id;
    final String title;
    final String author;
    final String isbn;
    final int publishedYear;
    final int totalCopies;
    final int availableCopies;
    final String? description;

    bool get isAvailable => availableCopies > 0;

    Book copyWith({int? availableCopies})
    {
      return Book(
        id: id,
        title: title,
        author: author,
        isbn: isbn,
        publishedYear: publishedYear,
        totalCopies: totalCopies,
        availableCopies: availableCopies ?? this.availableCopies,
        description: description,
      );
    }
}