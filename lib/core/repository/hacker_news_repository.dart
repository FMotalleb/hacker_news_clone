import 'dart:convert';

import 'package:hacker_news_clone/core/contracts/data_sources/http.dart';
import 'package:hacker_news_clone/core/contracts/data_sources/local.dart';
import 'package:hacker_news_clone/core/contracts/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/core/models/double_tap.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/models/response_model.dart';
import 'package:hemend_logger/hemend_logger.dart';

enum HNFeedType {
  topStories('topstories.json'),
  newStories('newstories.json'),
  bestStories('beststories.json'),
  ;

  const HNFeedType(this.endpoint);
  final String endpoint;
}

class HNRepository extends IHNewsRepository with LogableObject {
  HNRepository(this._httpDataSource, this._localRawSource);

  final IHttpDataSource<HackerNewsItem> _httpDataSource;
  final ILocalDataSource<String?> _localRawSource;
  static const _maxItemKey = 0xFFFFFF0F;

  static const _feedStorageBaseOffset = 0xFFFFFE00;

  @override
  String get loggerName => 'HN-Repository';

  @override
  CachedResult<List<int>> topStories() => //
      _getFeedsFor(HNFeedType.topStories);

  @override
  CachedResult<List<int>> newStories() => //
      _getFeedsFor(HNFeedType.newStories);

  @override
  CachedResult<List<int>> bestStories() => //
      _getFeedsFor(HNFeedType.bestStories);
  @override
  CachedResult<HackerNewsItem> getItem(int id) {
    fine('received a request to get item `$id`');
    final key = id;
    final endpoint = 'item/$id.json';
    final fromCache = _localRawSource.get(key).then(
      (value) {
        if (value is String) {
          finest('local storage has data for item `$id`');
          return jsonDecode(value) as Map<String, dynamic>;
        }
        return null;
      },
    );

    final requestResult = _httpDataSource
        .get(endpoint)
        .then(
          (value) => switch (value) {
            final Ok<HackerNewsItem> result => result.data,
            _ => null,
          },
        )
        .then(
      (value) async {
        if (value is Iterable<int>) {
          await _localRawSource.set(
            key,
            jsonEncode(value),
          );
          return value;
        }
        return null;
      },
    );
    final result = CachedResult(
      fromCache.then((value) {
        if (value is Map) {
          return HackerNewsItem.fromMap(value!);
        }
        return null;
      }),
      requestResult,
      () => _httpDataSource.discardRequestByHash(endpoint.hashCode),
    );
    return result;
  }

  CachedResult<List<int>> _getFeedsFor(HNFeedType feed) {
    fine('received a request to load feed of type `${feed.name}`');
    final key = feed.index + _feedStorageBaseOffset;
    final endpoint = feed.endpoint;
    final fromCache = _localRawSource.get(key).then(
      (value) {
        if (value is String) {
          finest('local storage has data for `${feed.name}`');
          return value.split(',');
        }
        return null;
      },
    ).then(
      (value) {
        if (value != null) {
          return value.map(int.parse);
        }
        return null;
      },
    );

    final requestResult = _httpDataSource
        .getRaw(endpoint)
        .then(
          (value) => switch (value) {
            final Ok<String> result => jsonDecode(result.data),
            _ => null,
          },
        )
        .then(
      (value) {
        if (value is List) {
          finest('`${feed.name}` received data from API');
          return value.whereType<int>();
        }
        return null;
      },
    ).then(
      (value) async {
        if (value is Iterable<int>) {
          await _localRawSource.set(
            key,
            value.join(','),
          );
          return value;
        }
        return null;
      },
    );
    final result = CachedResult(
      fromCache.then((value) => value?.toList()),
      requestResult.then((value) => value?.toList()),
      () => _httpDataSource.discardRequestByHash(endpoint.hashCode),
    );
    return result;
  }

  @override
  CachedResult<int> maxItemsCount() {
    final fromCache = _localRawSource.get(_maxItemKey).then(
      (value) {
        if (value != null) {
          return int.tryParse(value);
        }
        return null;
      },
    );
    const endpoint = 'maxitem.json';
    final requestResult = _httpDataSource
        .getRaw(endpoint)
        .then(
          (value) => switch (value) {
            final Ok<String> result => int.parse(result.data),
            _ => null,
          },
        )
        .then(
      (value) async {
        if (value != null) {
          await _localRawSource.set(
            _maxItemKey,
            value.toString(),
          );
        }
        return value;
      },
    );

    return CachedResult(
      fromCache,
      requestResult,
      () => _httpDataSource.discardRequestByHash(endpoint.hashCode),
    );
  }
}
