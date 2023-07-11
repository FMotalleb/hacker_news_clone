import 'package:hacker_news_clone/core/contracts/data_sources/local.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalRawStore extends ILocalDataSource<String?> {
  LocalRawStore(this._box);

  final LazyBox<String> _box;
  @override
  Future<String?> get(int id) {
    return _box.get(id);
  }

  @override
  Future<void> set(int id, String? data) {
    if (data == null) {
      return unset(id);
    }
    return _box.put(id, data);
  }

  @override
  Future<bool> unset(int id) => _box
      .delete(id)
      .then(
        (_) => true,
      )
      .onError(
        (_, __) => false,
      );
}
