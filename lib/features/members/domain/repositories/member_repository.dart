import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member.dart';

abstract class MemberRepository {
  Future<Either<Failure, Member>> getMemberById(String id);
  Future<Either<Failure, Member>> updateMember(Member member);
}