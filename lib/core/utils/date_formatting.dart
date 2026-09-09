const _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "12 Sep" style, matching the mockups. Deliberately not pulling in the
/// intl package for one format string — its locale-aware machinery is
/// real weight for something this narrow. Revisit if the app ever needs
/// actual localization.
String formatShortDate(DateTime date) => '${date.day} ${_monthAbbreviations[date.month - 1]}';

/// "Returned Today" when it happened same-day, matching the mockup's
/// wording exactly — falls back to the plain short date otherwise.
String formatReturnedLabel(DateTime returnedDate) {
  final now = DateTime.now();
  final isToday = returnedDate.year == now.year && returnedDate.month == now.month && returnedDate.day == now.day;
  return isToday ? 'Returned Today' : 'Returned ${formatShortDate(returnedDate)}';
}