import 'failure.dart';

enum AppErrorType { notFound, server, unexpected }

AppErrorType appErrorTypeFrom(Failure failure) => switch (failure) {
      NotFoundFailure() => AppErrorType.notFound,
      ServerFailure() => AppErrorType.server,
      _ => AppErrorType.unexpected,
    };
