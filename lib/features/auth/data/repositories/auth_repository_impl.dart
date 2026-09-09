import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._sessionStorage);
  final AuthLocalDataSource _dataSource;
  final SecureSessionStorage _sessionStorage;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _dataSource.login(email: email, password: password);
      final session = model.toEntity();
      await _sessionStorage.save(session);
      return Right(session);
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final model = await _dataSource.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(model.toEntity());
    } on EmailAlreadyExistsException catch (e) {
      return Left(EmailAlreadyExistsFailure(e.message));
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
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _sessionStorage.clear();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}