import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'theme/app_theme.dart';
import '../features/home/home_screen.dart';

class ThayaNetrikApp extends ConsumerWidget {
  const ThayaNetrikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider); // Listen for reactive language switching

    return MaterialApp(
      title: 'Thaya Netrik — தாய நேத்ரிக்',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
