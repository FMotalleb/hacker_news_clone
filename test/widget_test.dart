// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:hacker_news_clone/core/contracts/data_sources/local.dart';
import 'package:hacker_news_clone/core/contracts/typedefs.dart';
import 'package:hacker_news_clone/core/data_sources/http.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';

typedef TestType = ({int time});
void main() async {
  const mes =
      '{"by":"xena","descendants":0,"id":36846389,"score":1,"time":1690199558,"title":"Pokémon Crystal AI – Scientifically Ranking the Pokémon Crystal Trainers","type":"story","url":"https://www.youtube.com/watch?v=Q6E6OaWb7LQ"}'; // final TestType item = (time: DateTime.now());
  final input = jsonDecode(mes); // DateTime time;
  // TestType item = (time: 0);

  print(HackerNewsItem.fromMap(input as Json));
  // final data = await HNRepository(HttpSource(), LocalRawSource()).getItem(809).toList();
  // print(data);
}

class LocalRawSource extends ILocalDataSource<String?> {
  @override
  Future<String?> get(int id) => Future.value(null);

  @override
  Future<void> set(int id, String? data) => Future.value(null);

  @override
  Future<bool> unset(int id) => Future.value(true);
}
