import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hacker_news_clone/core/exceptions/parser_exception.dart';

sealed class HackerNewsItem extends Equatable {
  const HackerNewsItem();

  factory HackerNewsItem.fromMap(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'story':
        return HNStory.fromJson(data);
      case 'comment':
        return HNComment.fromJson(data);
      default:
        throw ParserException('this type of HN item is not supported yet');
    }
  }
  int get id;
  String? get text;
  String get by;
  DateTime get time;
  bool get dead;
  List<int> get kids;
  Map<String, dynamic> toMap();
  String toJson() => jsonEncode(toMap());
}

class HNStory extends HackerNewsItem {
  const HNStory({
    required this.by,
    required this.dead,
    required this.id,
    required this.kids,
    required this.text,
    required this.time,
    required this.score,
    required this.url,
  });
  factory HNStory.fromJson(Map<String, dynamic> data) {
    return switch (data) {
      {
        'by': final String by,
        'id': final int id,
        // 'kids': final Iterable<dynamic> kids,
        'score': final int score,
        'time': final int time,
        'title': final String text,
        'type': 'story',
        // 'url': final String? url,
      } =>
        HNStory(
          by: by,
          id: id,
          // ignore: avoid_dynamic_calls, inference_failure_on_collection_literal
          kids: ((data['kids'] ?? []) as Iterable<dynamic>).whereType<int>().toList(),
          score: score,
          time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
          text: text,
          dead: data['dead'] != null && data['dead'] == true,
          url: data['url'] != null ? Uri.tryParse(data['url'].toString()) : null,
        ),
      _ => throw ParserException('Cannot parse map to HNStory')
    };
  }
  @override
  final String by;

  @override
  final bool dead;

  @override
  final int id;

  @override
  final List<int> kids;

  final int score;

  @override
  final String text;

  @override
  final DateTime time;
  final Uri? url;

  @override
  List<Object?> get props => [
        by,
        dead,
        id,
        kids,
        text,
        time,
        score,
        url,
      ];

  @override
  Map<String, dynamic> toMap() => {
        'by': by,
        'id': id,
        'kids': kids,
        'score': score,
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'title': text,
        'type': 'story',
        'url': url.toString(),
      };
}

class HNComment extends HackerNewsItem {
  const HNComment({
    required this.by,
    required this.dead,
    required this.id,
    required this.kids,
    required this.text,
    required this.parent,
    required this.time,
  });
  factory HNComment.fromJson(Map<String, dynamic> data) {
    return switch (data) {
      {
        'by': final String by,
        'id': final int id,
        'parent': final int parentId,
        'kids': final List<dynamic> kids,
        'time': final int time,
        'title': final String text,
        'type': 'comment',
      } =>
        HNComment(
          by: by,
          id: id,
          parent: parentId,
          kids: kids.whereType<int>().toList(),
          time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
          text: text,
          dead: data['dead'] != null && data['dead'] == true,
        ),
      _ => throw ParserException('Cannot parse map to HNComment')
    };
  }
  @override
  final String by;

  @override
  final bool dead;

  @override
  final int id;

  @override
  final List<int> kids;

  @override
  final String text;

  @override
  final DateTime time;
  final int parent;

  @override
  List<Object?> get props => [
        by,
        dead,
        id,
        kids,
        parent,
        text,
        time,
      ];

  @override
  Map<String, dynamic> toMap() => {
        'by': by,
        'id': id,
        'parent': parent,
        'kids': kids,
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'title': text,
        'type': 'comment',
      };
}
