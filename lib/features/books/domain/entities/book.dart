class Book {
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

  /// Default fallback state for initializations or tests
  factory Book.empty() => const Book(
        id: '',
        title: '',
        author: '',
        isbn: '',
        publishedYear: 1970,
        totalCopies: 0,
        availableCopies: 0,
        description: null,
      );

  final String id;
  final String title;
  final String author;
  final String isbn;
  final int publishedYear;
  final int totalCopies;
  final int availableCopies;
  final String? description;

  /// Business logic getter
  bool get isAvailable => availableCopies > 0;

  /// Allows updating properties without mutating original instances
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    int? publishedYear,
    int? totalCopies,
    int? availableCopies,
    String? description,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      publishedYear: publishedYear ?? this.publishedYear,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      description: description ?? this.description,
    );
  }

    /// Business rule from the spec: "Borrowing a book should reduce
  /// AvailableCopies by 1." This is where `copyWith` finally earns its
  /// keep from Phase 2 — the entity produces a new, valid Book rather
  /// than anyone mutating availableCopies directly from outside.
  Book borrowCopy() {
    assert(isAvailable, 'borrowCopy() called on an unavailable book — check isAvailable first.');
    return copyWith(availableCopies: availableCopies - 1);
  }

  /// "Returning a book should increase AvailableCopies by 1."
  Book returnCopy() {
    final next = availableCopies + 1;
    assert(next <= totalCopies, 'returnCopy() would exceed totalCopies — data is inconsistent.');
    return copyWith(availableCopies: next > totalCopies ? totalCopies : next);
  }
}