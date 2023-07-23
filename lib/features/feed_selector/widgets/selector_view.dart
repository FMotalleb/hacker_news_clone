import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';

class SelectorSegment extends StatelessWidget {
  const SelectorSegment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedSelectorCubit, FeedSelectorState>(
      builder: (context, state) {
        return NavigationBar(
          destinations: HNFeedType.values
              .map(
                (e) => NavigationDestination(
                  icon: getIconOf(e),
                  label: getNameOf(e),
                  selectedIcon: getActiveIconOf(e),
                ),
              )
              .toList(),
          animationDuration: const Duration(milliseconds: 350),
          onDestinationSelected: (value) {
            context.read<FeedSelectorCubit>().switchFeed(
                  HNFeedType.values[value],
                );
          },
          selectedIndex: HNFeedType.values.indexOf(state.feedType),
        );
      },
    );
  }

  String getNameOf(HNFeedType feed) {
    return switch (feed) {
      HNFeedType.bestStories => 'Best',
      HNFeedType.newStories => 'New',
      HNFeedType.topStories => 'Top',
    };
  }

  Widget getIconOf(HNFeedType feed) {
    return switch (feed) {
      HNFeedType.bestStories => const Icon(Icons.star_rate_rounded),
      HNFeedType.newStories => const Icon(Icons.newspaper_rounded),
      HNFeedType.topStories => const Icon(Icons.thumb_up_off_alt_rounded),
    };
  }

  Widget getActiveIconOf(HNFeedType feed) {
    return switch (feed) {
      HNFeedType.bestStories => const Icon(
          Icons.star_rate_rounded,
          shadows: [
            BoxShadow(
              offset: Offset(1, 3),
            ),
          ],
        ),
      HNFeedType.newStories => const Icon(
          Icons.newspaper_rounded,
          shadows: [
            BoxShadow(
              offset: Offset(1, 3),
            ),
          ],
        ),
      HNFeedType.topStories => const Icon(
          Icons.thumb_up_off_alt_rounded,
          shadows: [
            BoxShadow(
              offset: Offset(1, 3),
            ),
          ],
        ),
    };
  }
}
