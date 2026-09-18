import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_keycloak_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._sessionStorage);
  final AuthKeycloakDataSource _dataSource;
  final SecureSessionStorage _sessionStorage;

  @override
  Future<Either<Failure, AuthSession>> login() async {
    try {
      final model = await _dataSource.login();
      final session = model.toEntity();
      await _sessionStorage.save(session);
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register() async {
    try {
      final model = await _dataSource.register();
      final session = model.toEntity();
      await _sessionStorage.save(session);
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() async {
    try {
      return Right(await _sessionStorage.read());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    try {
      final current = await _sessionStorage.read();
      if (current == null) {
        return const Left(InvalidRefreshTokenFailure('No active session to refresh.'));
      }
      final model = await _dataSource.refresh(refreshToken: current.refreshToken);
      // Keycloak's refresh grant doesn't always re-issue an id_token — keep
      // the last known one so end-of-session logout still has a hint later.
      var session = model.toEntity();
      if (session.idToken == null && current.idToken != null) {
        session = _withIdToken(session, current.idToken);
      }
      await _sessionStorage.save(session);
      return Right(session);
    } on InvalidRefreshTokenException catch (e) {
      await _sessionStorage.clear(); // don't leave a dead/rotated token lying around
      return Left(InvalidRefreshTokenFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final current = await _sessionStorage.read();
      if (current?.idToken != null) {
        // Best-effort: an app-level logout should still succeed locally even
        // if Keycloak (or the network) can't be reached to end the SSO
        // session — the user would otherwise be stuck "logged in".
        try {
          await _dataSource.endSession(idToken: current!.idToken!);
        } catch (_) {}
      }
      await _sessionStorage.clear();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  AuthSession _withIdToken(AuthSession session, String? idToken) => AuthSession(
        accessToken: session.accessToken,
        accessTokenExpiresAt: session.accessTokenExpiresAt,
        refreshToken: session.refreshToken,
        refreshTokenExpiresAt: session.refreshTokenExpiresAt,
        userId: session.userId,
        role: session.role,
        fullName: session.fullName,
        email: session.email,
        idToken: idToken,
      );
}