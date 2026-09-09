import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}