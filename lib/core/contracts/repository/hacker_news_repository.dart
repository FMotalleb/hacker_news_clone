import 'package:hacker_news_clone/core/models/double_tap.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';

abstract class IHNewsRepository {
  CachedResult<int> maxItemsCount();
  CachedResult<List<int>> topStories();
  CachedResult<List<int>> newStories();
  CachedResult<List<int>> bestStories();
  CachedResult<HackerNewsItem> getItem(int id);
}
