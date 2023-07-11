import 'dart:async';
import 'package:rxdart/rxdart.dart' as rx;

class CachedResult<T> extends Stream<T> {
  factory CachedResult(
    Future<T> fromCache,
    Future<T> toWaitFor,
  ) {
    final stream = rx.DeferStream(
      () => Stream.fromFutures(
        [
          fromCache,
          toWaitFor,
        ],
      ),
    );
    return CachedResult._(stream);
  }

  CachedResult._(
    this._dataStream,
  );
  final Stream<T> _dataStream;
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _dataStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
