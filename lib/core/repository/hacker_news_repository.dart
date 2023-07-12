import 'package:hacker_news_clone/core/contracts/data_sources/http.dart';
import 'package:hacker_news_clone/core/contracts/data_sources/local.dart';
import 'package:hacker_news_clone/core/contracts/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/core/models/double_tap.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/models/response_model.dart';
import 'package:hemend_logger/hemend_logger.dart';

class HNRepository extends IHNewsRepository with LogableObject {
  HNRepository(this._httpDataSource, this._localRawSource);

  final IHttpDataSource<HackerNewsItem> _httpDataSource;
  final ILocalDataSource<String?> _localRawSource;
  static const _maxItemKey = 0xFFFFFFFE;

  @override
  CachedResult<int> maxItemsCount() {
    final fromCache = _localRawSource
        .get(_maxItemKey)
        .then(
          (value) => value,
        )
        .then(
      (value) {
        if (value != null) {
          return int.tryParse(value);
        }
        return null;
      },
    );

    final requestResult = _httpDataSource
        .getRaw('maxitem.json')
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
    );
  }

  @override
  String get loggerName => 'HN-Repository';
}
