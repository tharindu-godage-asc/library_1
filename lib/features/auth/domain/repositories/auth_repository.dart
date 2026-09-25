import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login();

  Future<Either<Failure, AuthSession>> register();

  Future<Either<Failure, AuthSession?>> restoreSession();

  /// Redeems the current session's refresh token for a fresh access +
  /// refresh token pair (rotation) via the currently persisted session —
  /// no refresh token is threaded through as a parameter.
  Future<Either<Failure, AuthSession>> refreshSession();

  Future<Either<Failure, Unit>> logout();
}