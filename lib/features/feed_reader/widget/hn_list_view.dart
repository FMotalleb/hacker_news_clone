import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/features/feed_reader/cubit/feed_reader_cubit.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HNItemsListView extends StatelessWidget {
  const HNItemsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedSelectorCubit, FeedSelectorState>(
      builder: (
        context,
        state,
      ) =>
          BlocProvider(
        key: ValueKey(state.feedType),
        create: (context) => FeedReaderCubit(
          state.feedType,
          context.read(),
        ),
        child: const _HNItemsListViewPresentation(),
      ),
    );
  }
}

class _HNItemsListViewPresentation extends StatelessWidget {
  const _HNItemsListViewPresentation();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedReaderCubit, FeedReaderState>(
      builder: (context, state) {
        return switch (state) {
          final FeedReaderInformationUpdate update => ListView.builder(
              itemBuilder: (context, index) {
                final itemId = update.items[index];
                return HNStoryView(itemId: itemId);
              },
              itemCount: update.itemsCount,
            ),
          final _ => const Center(
              child: CircularProgressIndicator(),
            ),
        };
      },
    );
  }
}

class HNStoryView extends StatefulWidget {
  const HNStoryView({
    super.key,
    required this.itemId,
  });

  final int itemId;

  @override
  State<HNStoryView> createState() => _HNStoryViewState();
}

class _HNStoryViewState extends State<HNStoryView> {
  Future<void> Function()? onDeath;
  @override
  void dispose() {
    unawaited(onDeath?.call());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fetch = context.read<HNRepository>().getItem(widget.itemId);
    onDeath = fetch.discardFetching;
    return StreamBuilder(
      stream: fetch,
      builder: (context, state) {
        final data = state.data;
        if (data is! HNStory) {
          if (state.connectionState == ConnectionState.done) {
            return const SizedBox();
          }
          return const SizedBox(
            height: 100,
            child: Center(
              child: SizedBox(
                height: 2,
                width: 50,
                child: LinearProgressIndicator(),
              ),
            ),
          );
        }
        final fullText = data.text;
        return Column(
          children: [
            Container(
              height: 2,
              color: Theme.of(context).shadowColor,
            ),
            ExpansionTile(
              title: Text(fullText),
              leading: Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.yellow,
                  ),
                ),
                child: Text(data.score.toString()),
              ),
              // expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: const Alignment(-0.9, 0),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),

              // initiallyExpanded: true,
              children: [
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: 'By '),
                      TextSpan(text: data.by),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: 'At '),
                      _formatDate(data),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: data.kids.length.toString()),
                      const TextSpan(text: ' comments'),
                    ],
                  ),
                ),
                if (data.url != null)
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'Url: '),
                        TextSpan(
                          text: data.url!.host,
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                data.url!,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (data.url != null)
                  SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    child: ButtonBar(
                      // mainAxisSize: MainAxisSize.min,

                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final baseUri = Uri.parse(
                              'https://news.ycombinator.com/item',
                            ).replace(
                              queryParameters: {
                                'id': data.id.toString(),
                              },
                            );
                            launchUrl(
                              baseUri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: const Text('Open in HN'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final baseUri = Uri.parse(
                              'https://news.ycombinator.com/item',
                            ).replace(
                              queryParameters: {
                                'id': data.id.toString(),
                              },
                            );
                            Share.share(baseUri.toString());
                            // launchUrl(
                            //   data.url!,
                            //   mode: LaunchMode.externalApplication,
                            // );
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(
                              data.url!,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: const Text('open'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

TextSpan _formatDate(HackerNewsItem data) {
  final time = data.time.toLocal();
  final buffer = StringBuffer()
    ..write(time.year)
    ..write('-')
    ..write(time.month.toString().padLeft(2, '0'))
    ..write('-')
    ..write(time.day.toString().padLeft(2, '0'))
    ..write(' ')
    ..write(time.hour.toString().padLeft(2, '0'))
    ..write(':')
    ..write(time.minute.toString().padLeft(2, '0'));
  return TextSpan(text: buffer.toString());
}
