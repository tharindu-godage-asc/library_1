class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;
}

class UnexpectedException implements Exception {
  const UnexpectedException(this.message);
  final String message;
}