import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> = Future<Either<Exception, T>>;

typedef FutureVoid = Future<Either<Exception, void>>;

typedef FutureEitherList<T> = FutureEither<List<T>>;
