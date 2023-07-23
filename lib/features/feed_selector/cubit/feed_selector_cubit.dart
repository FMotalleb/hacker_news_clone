import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';

part 'feed_selector_state.dart';

class FeedSelectorCubit extends Cubit<FeedSelectorState> {
  FeedSelectorCubit()
      : super(
          const FeedSelectorState(
            feedType: HNFeedType.newStories,
          ),
        );

  void switchFeed(HNFeedType feed) => emit(
        FeedSelectorState(
          feedType: feed,
        ),
      );
}
