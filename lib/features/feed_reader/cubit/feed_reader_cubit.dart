import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/models/double_tap.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hemend_logger/hemend_logger.dart';

part 'feed_reader_state.dart';

class FeedReaderCubit extends Cubit<FeedReaderState> with LogableObject {
  FeedReaderCubit(
    this.feedType,
    this.repository,
  ) : super(FeedReaderInitial()) {
    unawaited(getItems());
  }
  final HNFeedType feedType;
  final HNRepository repository;
  Future<void> Function()? _dismissRequest;

  @override
  Future<void> close() async {
    if (_dismissRequest != null) {
      info('closing the request');
      unawaited(_dismissRequest!());
    }

    return super.close();
  }

  Future<void> getItems() async {
    final CachedResult<List<int>> result;
    switch (feedType) {
      case HNFeedType.bestStories:
        result = repository.bestStories();
      case HNFeedType.newStories:
        result = repository.newStories();
      case HNFeedType.topStories:
        result = repository.topStories();
    }
    _dismissRequest = result.discardFetching;
    await for (final i in result) {
      emit(
        FeedReaderInformationUpdate(
          itemsCount: i.length,
          items: i,
        ),
      );
    }
  }

  @override
  String get loggerName => 'FeedReaderCubit';
}
