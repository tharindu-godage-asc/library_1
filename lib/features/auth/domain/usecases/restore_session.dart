import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession?>> call() => _repository.restoreSession();
}