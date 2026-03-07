import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/app_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ManejaApp(),
    ),
  );
}

class ManejaApp extends StatelessWidget {
  const ManejaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maneja',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
