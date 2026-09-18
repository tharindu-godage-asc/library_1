class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UnexpectedException implements Exception {
  const UnexpectedException(this.message);
  final String message;

  @override
  String toString() => message;
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException(this.message);
  final String message;

  @override
  String toString() => message;
}

class EmailAlreadyExistsException implements Exception {
  const EmailAlreadyExistsException(this.message);
  final String message;

  @override
  String toString() => message;
}

class InvalidRefreshTokenException implements Exception {
  const InvalidRefreshTokenException(this.message);
  final String message;

  @override
  String toString() => message;
}
