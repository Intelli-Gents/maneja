import 'package:flutter/material.dart';
import 'package:maneja/features/agent/presentation/agent_chat_screen.dart';

class AppBottomNavShell extends StatelessWidget {
  const AppBottomNavShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.body,
    required this.onRecordPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget body;
  final VoidCallback onRecordPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            body,
            Positioned(
              right: 16,
              bottom: 92,
              child: FloatingActionButton(
                heroTag: 'maneja_agent_fab',
                elevation: 8,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AgentChatScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: const Icon(Icons.chat_bubble_rounded),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onRecordPressed,
        label: const Text(
          'Record',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: currentIndex,
        onTabSelected: onTabSelected,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomItem(
                index: 0,
                currentIndex: currentIndex,
                label: 'Home',
                icon: Icons.today_rounded,
                onTap: onTabSelected,
              ),
              _BottomItem(
                index: 1,
                currentIndex: currentIndex,
                label: 'Sales',
                icon: Icons.point_of_sale_rounded,
                onTap: onTabSelected,
              ),
              const SizedBox(width: 40),
              _BottomItem(
                index: 2,
                currentIndex: currentIndex,
                label: 'Stock',
                icon: Icons.inventory_2_rounded,
                onTap: onTabSelected,
              ),
              _BottomItem(
                index: 3,
                currentIndex: currentIndex,
                label: 'Insights',
                icon: Icons.bar_chart_rounded,
                onTap: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

