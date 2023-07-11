// enum HNItemType {
//   job,
//   story,
//   comment,
//   poll,
//   pollopt,
//   ;

//   factory HNItemType.fromJson(String key) {
//     return HNItemType.values.firstWhere((element) => element.name == key);
//   }
// }

import 'package:equatable/equatable.dart';

sealed class HackerNewsItem extends Equatable {
  const HackerNewsItem();
  int get id;
  String? get text; // HTML
  // HNItemType get type;
  String get by;
  DateTime get time;
  bool get dead;
  int? get parent;
  List<int> get kids;
  // Uri? get url;
  // int? get score;
  // String? get title; // HTML
  // descendants, parts, poll
  factory HackerNewsItem.fromMap(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'story':
        throw UnimplementedError('this type of HN item is not supported yet');
        break;
      case 'comment':
        throw UnimplementedError('this type of HN item is not supported yet');
        break;
      default:
        throw UnimplementedError('this type of HN item is not supported yet');

      // "job", "poll", or "pollopt"
    }
  }
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
  }) : parent = null;
  factory HNStory.fromJson(Map<String, dynamic> data) {
    return switch (data) {
      {
        'by': final String by,
        'id': final int id,
        'kids': final List<int> kids,
        'score': final int score,
        'time': final int time,
        'title': final String text,
        'type': 'story',
        'url': final String? url,
      } =>
        HNStory(
          by: by,
          id: id,
          kids: kids,
          score: score,
          time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
          text: text,
          dead: data['dead'] != null && data['dead'] == true,
          url: url != null ? Uri.tryParse(url) : null,
        ),
      _ => throw Exception('Cannot parse map to HNStory')
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
  final int? parent;

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
