import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

class GetMember {
  const GetMember(this._repository);
  final MemberRepository _repository;

  Future<Either<Failure, Member>> call(String id) => _repository.getMemberById(id);
}