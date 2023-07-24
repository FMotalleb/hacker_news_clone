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
      '{"by":"akasakahakada","descendants":1,"id":36844840,"kids":[36846275],"score":8,"text":"I have noticed that google search resulting hamful&#x2F;phishing&#x2F;fake&#x2F;fraud websites in recent month.<p>No matter what I search, those junks keep showing up.<p>They are all with different url and look legit like .gov, .br, .com, .edu etc. Some even mimic real company by only differing 1 character in the domain. But those are not real, when you click that it will just redirect to the scam site.<p>One common characteristic is that most of them are non titled website. Google search will tell me that the page has no title. And the preview beneath that are all random garbage that are copied from random sites by bot.<p>With a little search, it seems that I am being DNS hijacked. But using 3 different devices and networks, I can confirm that the weird behavior is consistent.<p>WhoIsMyDns.com reports that my DNS are all from cloudflare.<p>What is going on?","time":1690189158,"title":"Ask HN: Am I the only one that has broken Google search results?","type":"story"}';
  // final TestType item = (time: DateTime.now());
  // DateTime time;
  // TestType item = (time: 0);

  print(HackerNewsItem.fromMap(jsonDecode(mes) as Json));
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
