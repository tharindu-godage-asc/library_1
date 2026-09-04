/// Thrown by data sources. The repository is what maps these into
/// domain-level Failures — nothing above the repository should ever
/// see or catch one of these directly.
class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;
}

class UnexpectedException implements Exception {
  const UnexpectedException(this.message);
  final String message;
}