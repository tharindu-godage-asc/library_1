import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RefreshSession {
  const RefreshSession(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession>> call() => _repository.refreshSession();
}
