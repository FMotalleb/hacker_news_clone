import 'dart:async';
import 'package:rxdart/rxdart.dart' as rx;

class CachedResult<T> extends Stream<T> {
  factory CachedResult(
    Future<T?> fromCache,
    Future<T?> toWaitFor,
    Future<void> Function() discard,
  ) {
    final stream = rx.DeferStream(
      () => Stream.fromFutures(
        [
          fromCache,
          toWaitFor,
        ],
      ),
    ).whereType<T>();
    return CachedResult._(stream, discard);
  }

  CachedResult._(
    this._dataStream,
    this.discardFetching,
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

  Future<void> Function() discardFetching;
}
