import 'package:hacker_news_clone/core/data_sources/http.dart';
import 'package:hacker_news_clone/core/data_sources/local_raw_storage.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hive/hive.dart';

HNRepository makeHnRepository(LazyBox<String> box) {
  return HNRepository(
    HttpSource(),
    LocalRawStore(box),
  );
}
