import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_local_datasource.dart';
import '../models/member_model.dart';

class MemberRepositoryImpl implements MemberRepository {
  const MemberRepositoryImpl(this._dataSource);
  final MemberLocalDataSource _dataSource;

  @override
  Future<Either<Failure, Member>> getMemberById(String id) async {
    try {
      final model = await _dataSource.fetchById(id);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> updateMember(Member member) async {
    try {
      final model = await _dataSource.update(MemberModel.fromEntity(member));
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on EmailAlreadyExistsException catch (e) {
      return Left(EmailAlreadyExistsFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}