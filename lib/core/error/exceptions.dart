class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;
}

class UnexpectedException implements Exception {
  const UnexpectedException(this.message);
  final String message;
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException(this.message);
  final String message;
}

class EmailAlreadyExistsException implements Exception {
  const EmailAlreadyExistsException(this.message);
  final String message;
}