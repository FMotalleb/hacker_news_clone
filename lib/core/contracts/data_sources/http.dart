import 'package:hacker_news_clone/core/models/response_model.dart' //
    as internal;

// ignore: one_member_abstracts
abstract class IHttpDataSource<T> {
  Future<internal.Response<T>> get(String path);
  Future<internal.Response<String>> getRaw(String path);
  Future<void> discardRequestByHash(int hash);
}
