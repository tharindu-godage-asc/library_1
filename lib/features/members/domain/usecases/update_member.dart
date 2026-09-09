import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

class UpdateMember {
  const UpdateMember(this._repository);
  final MemberRepository _repository;

  Future<Either<Failure, Member>> call(Member member) => _repository.updateMember(member);
}