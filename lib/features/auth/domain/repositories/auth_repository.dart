import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  /// No `role` parameter — that's deliberate, not an oversight. Public
  /// registration always creates a Member; enforcing that by never
  /// accepting a role here means there's no code path that could
  /// accidentally let a caller register as Admin.
  Future<Either<Failure, AuthSession>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, AuthSession?>> restoreSession();

  /// Redeems the current session's refresh token for a fresh access +
  /// refresh token pair (rotation) via the currently persisted session —
  /// no refresh token is threaded through as a parameter.
  Future<Either<Failure, AuthSession>> refreshSession();

  Future<Either<Failure, Unit>> logout();
}