import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);
  final AuthLocalDataSource _dataSource;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _dataSource.login(email: email, password: password);
      return Right(model.toEntity());
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
}