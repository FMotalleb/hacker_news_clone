import 'package:equatable/equatable.dart';

sealed class Response<T> extends Equatable {
  const Response();

  factory Response.ok(T data) => Ok._(data);
  factory Response.missing() => const Missing._();
  factory Response.unknown() => const UnknownError._();
  factory Response.error(
    int statusCode,
    String statusMessage,
  ) {
    if (statusCode == 404) {
      return Response.missing();
    }
    return Failed._(
      statusCode: statusCode,
      statusMessage: statusMessage,
    );
  }
}

class Ok<T> extends Response<T> {
  const Ok._(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

class Failed<T> extends Response<T> {
  const Failed._({
    required this.statusCode,
    required this.statusMessage,
  });
  final int statusCode;
  final String statusMessage;

  @override
  List<Object?> get props => [statusCode];
}

class Missing<T> extends Failed<T> {
  const Missing._()
      : super._(
          statusCode: 404,
          statusMessage: 'missing',
        );
}

class UnknownError<T> extends Failed<T> {
  const UnknownError._()
      : super._(
          statusCode: -1,
          statusMessage: 'unknown error',
        );
}
