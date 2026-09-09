sealed class Failure {
  const Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(super.message);
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure(super.message);
}

class BookUnavailableFailure extends Failure {
  const BookUnavailableFailure(super.message);
}

class BorrowingLimitExceededFailure extends Failure {
  const BorrowingLimitExceededFailure(super.message);
}

class AlreadyReturnedFailure extends Failure {
  const AlreadyReturnedFailure(super.message);
}

class MemberInactiveFailure extends Failure {
  const MemberInactiveFailure(super.message);
}