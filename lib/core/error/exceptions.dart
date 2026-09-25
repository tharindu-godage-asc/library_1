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


/// A rejection from Library.Api's ProblemDetails responses, carrying the
/// backend's machine-readable `code` (e.g. "Book.NoAvailableCopies") so
/// callers can map it to a specific failure instead of a generic one.
class ApiProblemException implements Exception {
  const ApiProblemException({required this.statusCode, required this.code, required this.message});
  final int statusCode;
  final String? code;
  final String message;

  @override
  String toString() => message;
}
