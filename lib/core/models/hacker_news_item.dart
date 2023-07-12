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

      // "job", "poll", or "pollopt"
    }
  }
  int get id;
  String? get text; // HTML
  // HNItemType get type;
  String get by;
  DateTime get time;
  bool get dead;
  List<int> get kids;
  // Uri? get url;
  // int? get score;
  // String? get title; // HTML
  // descendants, parts, poll
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
    // ignore: avoid_field_initializers_in_const_classes
  });
  factory HNStory.fromJson(Map<String, dynamic> data) {
    return switch (data) {
      {
        'by': final String by,
        'id': final int id,
        'kids': final Iterable<dynamic> kids,
        'score': final int score,
        'time': final int time,
        'title': final String text,
        'type': 'story',
        'url': final String? url,
      } =>
        HNStory(
          by: by,
          id: id,
          kids: kids.whereType<int>().toList(),
          score: score,
          time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
          text: text,
          dead: data['dead'] != null && data['dead'] == true,
          url: url != null ? Uri.tryParse(url) : null,
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
    // ignore: avoid_field_initializers_in_const_classes
  });
  factory HNComment.fromJson(Map<String, dynamic> data) {
    return switch (data) {
      {
        'by': final String by,
        'id': final int id,
        'parent': final int parentId,
        'kids': final List<int> kids,
        'time': final int time,
        'title': final String text,
        'type': 'comment',
      } =>
        HNComment(
          by: by,
          id: id,
          parent: parentId,
          kids: kids,
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
}
