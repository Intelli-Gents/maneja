import 'package:flutter/material.dart';
import 'package:maneja/core/widgets/app_bottom_nav_shell.dart';
import 'package:maneja/features/home/presentation/home_screen.dart';
import 'package:maneja/features/insights/presentation/insights_screen.dart';
import 'package:maneja/features/input/presentation/input_hub_sheet.dart';
import 'package:maneja/features/sales/presentation/sales_screen.dart';
import 'package:maneja/features/stock/presentation/stock_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _openInputHub() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InputHubSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const SalesScreen(),
      const StockScreen(),
      const InsightsScreen(),
    ];

    return AppBottomNavShell(
      currentIndex: _index,
      onTabSelected: (value) {
        setState(() {
          _index = value;
        });
      },
      onRecordPressed: _openInputHub,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
    );
  }
}

