import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';
import 'package:hemend_logger/hemend_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class SelectorSegment extends StatelessWidget with LogableObject {
  const SelectorSegment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    config(
      'building navbar for: ${HNFeedType.values.map((e) => e.name).join(',')}',
    );
    return BlocBuilder<FeedSelectorCubit, FeedSelectorState>(
      builder: (context, state) {
        return NavigationBar(
          destinations: HNFeedType.values
              .map(
                (e) => NavigationDestination(
                  icon: getIconOf(e),
                  label: getNameOf(e),
                  selectedIcon: getActiveIconOf(context, e),
                ),
              )
              .toList(),
          animationDuration: const Duration(milliseconds: 350),
          onDestinationSelected: (value) {
            final feedType = HNFeedType.values[value];
            final lastFeedType = state.feedType;
            info(
              'selected feed type: ${lastFeedType.name} => ${feedType.name}',
            );
            if (feedType == lastFeedType) {
              fine('selected same feed again');
            } else {
              context.read<FeedSelectorCubit>().switchFeed(
                    feedType,
                  );
            }
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

  Widget getActiveIconOf(BuildContext context, HNFeedType feed) {
    final view = switch (feed) {
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
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        info('long press on active feed: request to load log files');
        final logger = Logger('LogsModal');
        unawaited(
          showLogModal(context, logger),
        );
      },
      child: view,
    );
  }

  Future<void> showLogModal(BuildContext context, Logger logger) async {
    final storageAddress = await getApplicationDocumentsDirectory();
    final logs = await storageAddress
        .list()
        .where(
          (event) => event.path.endsWith('.log'),
        )
        .whereType<File>()
        .toList();
    if (context.mounted) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            ...logs.map(
              (e) => CupertinoActionSheetAction(
                child: Text(e.uri.pathSegments.last),
                onPressed: () async {
                  logger.info(
                    'selected file ${e.uri.pathSegments.last} so loading ${e.path}',
                  );
                  final content = await e.readAsString();
                  if (context.mounted) {
                    await showCupertinoDialog<void>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(e.uri.pathSegments.last),
                        content: Text(
                          content,
                          textAlign: TextAlign.start,
                          textDirection: TextDirection.ltr,
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              await e.delete();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                              logger.warning(
                                  'Log ${e.uri.pathSegments.last} is deleted');
                            },
                            isDestructiveAction: true,
                            child: const Text('Delete'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            // isDestructiveAction: true,
                            child: const Text('close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  String get loggerName => 'NavBar';
}
