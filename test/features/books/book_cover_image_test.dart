import 'package:flutter_test/flutter_test.dart';
import 'package:library_1/features/books/presentation/widgets/book_cover_image.dart';

void main() {
  group('BookCoverImage.sizedUrl', () {
    const url = 'https://covers.openlibrary.org/b/id/12345-S.jpg';

    test('buckets to S at or below 120px', () {
      expect(BookCoverImage.sizedUrl(url, 120), endsWith('-S.jpg'));
      expect(BookCoverImage.sizedUrl(url, 1), endsWith('-S.jpg'));
    });

    test('buckets to M between 121 and 320px', () {
      expect(BookCoverImage.sizedUrl(url, 121), endsWith('-M.jpg'));
      expect(BookCoverImage.sizedUrl(url, 320), endsWith('-M.jpg'));
    });

    test('buckets to L above 320px', () {
      expect(BookCoverImage.sizedUrl(url, 321), endsWith('-L.jpg'));
      expect(BookCoverImage.sizedUrl(url, 4000), endsWith('-L.jpg'));
    });

    test('leaves a URL without an -S/-M/-L.jpg suffix unchanged', () {
      const noSuffix = 'https://example.com/cover.png';
      expect(BookCoverImage.sizedUrl(noSuffix, 200), noSuffix);
    });
  });
}
