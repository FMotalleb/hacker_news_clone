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

  final storageAddress = await getApplicationDocumentsDirectory();
  final logPath = Uri(
    pathSegments: [
      ...storageAddress.uri.pathSegments,
      'instance_${DateTime.now().millisecondsSinceEpoch}.log',
    ],
  );
  logAgent.addListener(
    HemendAsyncLogRecorder.file(
      logLevel: 900,
      stringify: (record) =>
          '[${record.loggerName}] (${record.level}):\n${record.message}\n---\n',
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
    return MaterialApp(
      title: 'Hacker News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hacker News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with LogableObject {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedSelectorCubit(),
      child: const Scaffold(
        body: HNItemsListView(),
        bottomNavigationBar: SelectorSegment(),
      ),
    );
  }

  @override
  String get loggerName => 'MainPage';
}
