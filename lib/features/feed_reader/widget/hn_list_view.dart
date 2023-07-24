import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/repository/hacker_news_repository.dart';
import 'package:hacker_news_clone/features/feed_reader/cubit/feed_reader_cubit.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';
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
                return StreamBuilder(
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
                          // initiallyExpanded: true,
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(text: 'By '),
                                      TextSpan(text: data.by),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(text: 'At '),
                                      _formatDate(data),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (data.url != null)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 15,
                                  ),
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
                                              launchUrl(data.url!);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                  stream: context.read<HNRepository>().getItem(itemId),
                );
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
}
