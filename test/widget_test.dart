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
  final input = {
    'by': 'shankys',
    'descendants': 1,
    'id': 809,
    'kids': [823],
    'score': 17,
    'time': 1172281307,
    'title':
        'Startup Success 2006 [video] - Panel moderated by Guy Kawasaki featuring Reid Hoffman (LinkedIn), Joe Kraus (Excite, Jotspot), and others',
    'type': 'story',
    'url': 'http://www.veotag.com/player/?u=gwbrgolswx'
  };
  const mes =
      '{"by":"howthisends","descendants":13,"id":36694686,"kids":[36695492,36695640,36695649,36695407,36694786,36695227],"score":34,"time":1689170529,"title":"AGI Simulator","type":"story","url":"https://agi.aitida.com/"}';
  // final TestType item = (time: DateTime.now());
  // DateTime time;
  // TestType item = (time: 0);

  print(HackerNewsItem.fromMap(jsonDecode(mes) as Json));
  final data = await HNRepository(HttpSource(), LocalRawSource()).getItem(809).toList();
  print(data);
}

class LocalRawSource extends ILocalDataSource<String?> {
  @override
  Future<String?> get(int id) => Future.value(null);

  @override
  Future<void> set(int id, String? data) => Future.value(null);

  @override
  Future<bool> unset(int id) => Future.value(true);
}
