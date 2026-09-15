import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/borrowing.dart';

abstract class BorrowingRepository {
  Future<Either<Failure, Borrowing>> createBorrowing(Borrowing borrowing);
  Future<Either<Failure, Borrowing>> updateBorrowing(Borrowing borrowing);
  Future<Either<Failure, List<Borrowing>>> getBorrowingsForMember(String memberId);
  Future<Either<Failure, Borrowing>> getBorrowingById(String id);
}