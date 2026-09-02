import '../models/book_model.dart';

/// Stands in for a real HTTP client. Data is built via fromJson from
/// Map literals — deliberately, so it's already shaped like it's coming
/// off the wire, not constructed as a convenient Dart object. That's
/// what makes swapping this for a real ApiBookDataSource in Phase 18
/// an implementation swap, not a rewrite.
class BookMockDataSource {
  final List<Map<String, dynamic>> _books = [
    {
      'id': 'b1', 'title': 'The Hobbit', 'author': 'J.R.R. Tolkien',
      'isbn': '9780547928227', 'publishedYear': 1937,
      'totalCopies': 4, 'availableCopies': 2,
      'description': 'Bilbo Baggins is swept from his quiet hobbit-hole '
          'into a sweeping quest across Middle-earth.',
    },
    {
      'id': 'b2', 'title': 'Dune', 'author': 'Frank Herbert',
      'isbn': '9780441172719', 'publishedYear': 1965,
      'totalCopies': 3, 'availableCopies': 0,
      'description': 'A stunning blend of adventure and mysticism, '
          'environmentalism and politics.',
    },
    {
      'id': 'b3', 'title': 'Atomic Habits', 'author': 'James Clear',
      'isbn': '9780735211292', 'publishedYear': 2018,
      'totalCopies': 5, 'availableCopies': 5,
      'description': 'Tiny changes, remarkable results — an easy and '
          'proven way to build good habits.',
    },
    {
      'id': 'b4', 'title': 'Ikigai', 'author': 'Héctor García',
      'isbn': '9780143130727', 'publishedYear': 2016,
      'totalCopies': 2, 'availableCopies': 1,
      'description': 'The Japanese secret to a long and happy life.',
    },
    {
      'id': 'b5', 'title': '1984', 'author': 'George Orwell',
      'isbn': '9780451524935', 'publishedYear': 1949,
      'totalCopies': 3, 'availableCopies': 1,
      'description': 'A dystopian social science fiction novel and '
          'cautionary tale.',
    },
    {
      'id': 'b6', 'title': 'Circe', 'author': 'Madeline Miller',
      'isbn': '9780316556347', 'publishedYear': 2018,
      'totalCopies': 4, 'availableCopies': 3,
      'description': 'In the house of Helios, god of the sun, a daughter '
          'is born who is unlike anyone before her.',
    },
  ];

  Future<List<BookModel>> fetchBooks() async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate latency
    return _books.map(BookModel.fromJson).toList();
  }

  Future<BookModel> fetchBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final match = _books.where((b) => b['id'] == id);
    if (match.isEmpty) {
      throw Exception('Book not found: $id');
    }
    return BookModel.fromJson(match.first);
  }
}