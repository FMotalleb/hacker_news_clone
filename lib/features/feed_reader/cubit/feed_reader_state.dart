part of 'feed_reader_cubit.dart';

abstract class FeedReaderState extends Equatable {
  const FeedReaderState();

  @override
  List<Object> get props => [];
}

class FeedReaderInitial extends FeedReaderState {}

class FeedReaderInformationUpdate extends FeedReaderState {
  const FeedReaderInformationUpdate({
    required this.itemsCount,
    required this.items,
  });

  final int itemsCount;
  final List<int> items;
  @override
  List<Object> get props => [
        itemsCount,
        items,
      ];
}
