// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';

import 'package:hacker_news_clone/main.dart';

typedef TestType = ({int time});
void main() {
  final input = {
    "by": "shankys",
    "descendants": 1,
    "id": 809,
    "kids": [823],
    "score": 17,
    "time": 1172281307,
    "title":
        "Startup Success 2006 [video] - Panel moderated by Guy Kawasaki featuring Reid Hoffman (LinkedIn), Joe Kraus (Excite, Jotspot), and others",
    "type": "story",
    "url": "http://www.veotag.com/player/?u=gwbrgolswx"
  };
  // final TestType item = (time: DateTime.now());
  // DateTime time;
  // TestType item = (time: 0);

  print(HNStory.fromJson(input));
}
