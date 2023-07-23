part of 'feed_selector_cubit.dart';

class FeedSelectorState extends Equatable {
  const FeedSelectorState({
    required this.feedType,
  });
  final HNFeedType feedType;

  @override
  List<Object?> get props => [feedType];
}
