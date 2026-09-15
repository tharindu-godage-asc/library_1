import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';

abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}

/*
 * UseCase Core Interface:
 * 
 * Provides a standardized abstract contract for all use cases (interactors) 
 * in the domain layer. Every use case must implement the call() method, 
 * accepting a generic [Params] type and returning an Either<Failure, Result>.
 * 
 * - NoParams: A lightweight helper class used for use cases that require 
 *   no input arguments to execute.
 */