import 'package:flutter/material.dart';

/// Sizing constants for the horizontal book shelves and their cards
/// (BooksScreen + BookVerticalCard), replacing the previous hard-coded
/// 110/180/200 literals with values derived from the available width.
class AppDimens {
  AppDimens._();

  /// Width:height ratio for book covers — a standard portrait
  /// paperback/hardcover proportion.
  static const bookCoverAspectRatio = 2 / 3;

  /// Card width never shrinks below this, even on the narrowest phones.
  static const bookCardMinWidth = 104.0;

  /// Card width never grows past this, even on tablets/landscape, so
  /// shelves don't look sparse with oversized cards.
  static const bookCardMaxWidth = 160.0;

  /// Fraction of the screen width a single shelf card should occupy on
  /// a typical phone, before min/max clamping applies.
  static const _bookCardWidthFraction = 0.30;

  /// Responsive width for a book shelf card, derived from screen width and
  /// clamped to [bookCardMinWidth]..[bookCardMaxWidth] so cards scale
  /// between phones and tablets/landscape instead of staying fixed.
  static double bookCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * _bookCardWidthFraction).clamp(bookCardMinWidth, bookCardMaxWidth).toDouble();
  }

  /// Height of a single rendered line of [style] text at [textScaler].
  ///
  /// Multiply by a line count and use it as a [SizedBox] height to reserve
  /// a fixed number of lines' worth of space — e.g. so a 1-line title
  /// doesn't end up shorter than a sibling card whose title wraps to 2
  /// lines. Derived from the font's real metrics (via [TextPainter])
  /// rather than a guessed pixel value, so it stays correct for any
  /// font/size and scales with the user's text-scale setting.
  static double lineHeight(TextStyle style, TextScaler textScaler) {
    return (TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout())
        .preferredLineHeight;
  }
}
