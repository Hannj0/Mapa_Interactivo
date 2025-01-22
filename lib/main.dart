import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/interactive_map.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,brightness: Brightness.light
      ),
      home: const InteractiveMapScreen(),
    );
  }
}