import 'package:hacker_news_clone/core/models/double_tap.dart';

abstract class IHNewsRepository {
  CachedResult<int> maxItemsCount();
}
