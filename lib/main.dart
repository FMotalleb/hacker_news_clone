import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacker_news_clone/features/feed_selector/cubit/feed_selector_cubit.dart';
import 'package:hacker_news_clone/features/feed_selector/widgets/selector_view.dart';
import 'package:hacker_news_clone/providers/repository_provider.dart';
import 'package:hemend_async_log_recorder/hemend_async_log_recorder.dart';
import 'package:hemend_logger/hemend_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'features/feed_reader/widget/hn_list_view.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  // Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  final logAgent = HemendLogger.defaultLogger();

  WidgetsFlutterBinding.ensureInitialized();

  final storageAddress = await getApplicationSupportDirectory();
  final segments = storageAddress.uri.pathSegments.toList();
  while (segments.last.isEmpty) {
    segments.removeLast();
  }
  final logPath = Uri(
    pathSegments: [
      '',
      ...segments,
      'instance_${DateTime.now().millisecondsSinceEpoch}.log',
    ],
  );

  logAgent.addListener(
    HemendAsyncLogRecorder.file(
      logLevel: 900,
      allocate: true,
      stringify: (record) => '[${record.loggerName}] (${record.level}):\n${record.message}\n---\n',
      filePath: logPath.toFilePath(),
    ),
  );
  Hive.init(storageAddress.path);
  final box = await Hive.openLazyBox<String>('information_cache');

  runApp(
    Provider(
      create: (_) => makeHnRepository(box),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: const Key('mamad'),
      create: (context) => FeedSelectorCubit(),
      child: MaterialApp(
        title: 'Hacker News',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Hacker News'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget with LogableObject {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HNItemsListView(),
      bottomNavigationBar: SelectorSegment(),
    );
  }

  @override
  String get loggerName => 'MainPage';
}
