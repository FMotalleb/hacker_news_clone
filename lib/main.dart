import 'package:flutter/material.dart';
import 'package:hacker_news_clone/core/data_sources/http.dart';
import 'package:hacker_news_clone/core/data_sources/local_raw_storage.dart';
import 'package:hacker_news_clone/core/models/double_tap.dart';
import 'package:hacker_news_clone/providers/repository_provider.dart';
import 'package:hemend_logger/hemend_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/repository/hacker_news_repository.dart';

Future<void> main() async {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  HemendLogger.defaultLogger();
  WidgetsFlutterBinding.ensureInitialized();
  Hive.init('./');
  final box = await Hive.openLazyBox<String>('test');

  runApp(
    Provider(
      create: (_) => repositoryProvider(box),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
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
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HNRepository>().maxItemsCount().forEach(info);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  String get loggerName => 'MapPage';
}
