import 'dart:io';

import 'package:binary_map_file/binary_map_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Count will be saved into map file'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String key = 'count';
  late final BinaryMapFile binaryMapFile;
  late final ValueNotifier<bool> initNotifier;
  late final ValueNotifier<int> countNotifier;
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    initNotifier = ValueNotifier<bool>(false);

    WidgetsBinding.instance.addPostFrameCallback((_) async => initialize());
  }

  Future<void> initialize() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final filePath = path.join(appDocumentsDir.path, 'file.dat');

    binaryMapFile = BinaryMapFile(path: filePath);
    await binaryMapFile.ensureInitialized();
    initNotifier.value = true;

    final count = binaryMapFile.getDefaultValue<int>(key, 0) ?? 0;
    countNotifier = ValueNotifier<int>(count);
  }

  Future<void> _incrementCounter() async {
    var count = binaryMapFile.getValue<int>(key) ?? 0;
    ++count;

    binaryMapFile.setValue<int>(key, count);
    await binaryMapFile.serialize();
    countNotifier.value = count;

    setState(() {
      ++_counter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: initNotifier,
          builder: (context, init, _) {
            if (!init) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Increase value and hot start the app to check saved value:',
                ),
                ValueListenableBuilder(
                    valueListenable: countNotifier,
                    builder: (context, count, _) {
                      return Text(
                        '$count',
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    }),
                const Text(
                  'This is normal counter:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
          valueListenable: initNotifier,
          builder: (context, init, _) {
            if (!init) {
              return const SizedBox();
            }

            return FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            );
          }),
    );
  }
}
