import 'failure.dart';

sealed class AppErrorType {
  const AppErrorType();
}

class NotFoundErrorType extends AppErrorType {
  const NotFoundErrorType();
}

class ServerErrorType extends AppErrorType {
  const ServerErrorType();
}

class UnexpectedErrorType extends AppErrorType {
  const UnexpectedErrorType();
}

/// The signed-in member exists but is barred from the action
/// (`MemberInactiveFailure`). Not reachable via any page-level provider
/// today — only ever produced as a mutation failure — kept explicit so
/// it isn't silently swallowed into [UnexpectedErrorType] if that changes.
class AccessDeniedErrorType extends AppErrorType {
  const AccessDeniedErrorType();
}

/// A business-rule rejection rather than an infrastructure failure
/// (book unavailable, borrowing limit, already returned, bad
/// credentials, email taken). Carries the real [Failure.message] since
/// these are user-facing rejections, not generic "something broke" text.
class BusinessRuleErrorType extends AppErrorType {
  const BusinessRuleErrorType(this.message);
  final String message;
}

/// Exhaustive over every `Failure` subtype — deliberately no wildcard
/// arm. `Failure` is sealed, so adding a 10th subtype (or reusing one of
/// the business-rule failures inside a page-level query provider) fails
/// to compile here until it's given an intentional mapping, instead of
/// silently rendering as a generic 500.
AppErrorType appErrorTypeFrom(Failure failure) => switch (failure) {
      NotFoundFailure() => const NotFoundErrorType(),
      ServerFailure() => const ServerErrorType(),
      UnexpectedFailure() => const UnexpectedErrorType(),
      MemberInactiveFailure() => const AccessDeniedErrorType(),
      BookUnavailableFailure() ||
      BorrowingLimitExceededFailure() ||
      AlreadyReturnedFailure() ||
      InvalidCredentialsFailure() ||
      EmailAlreadyExistsFailure() =>
        BusinessRuleErrorType(failure.message),
    };
