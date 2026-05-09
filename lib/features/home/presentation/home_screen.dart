import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maneja/core/theme/app_theme.dart';
import 'package:maneja/core/widgets/dashboard_widgets.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/features/home/presentation/notifications_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final notifications = ref.watch(notificationsProvider);

    final now = DateTime.now();
    final dateText = DateFormat('EEE, d MMM').format(now);
    const kioskName = 'Amos Merch';

    const pageBg = Color(0xFFF8F9FC);
    const textDark = AppTheme.textDark;
    const textMuted = Color(0xFF6B7280);
    const green = Color(0xFF34C77B);

    final currency = NumberFormat.compactCurrency(
      locale: 'en_UG',
      symbol: '',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$dateText • $kioskName',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: _NotificationsAvatar(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary.when(
                data: (s) => Row(
                  children: [
                    Expanded(
                      child: DashboardKpiCard(
                        title: 'Sales Today',
                        value: currency.format(s.todaySales),
                        unit: 'UGX',
                        icon: Icons.monetization_on_rounded,
                        iconBg: const Color(0xFFE5F8ED),
                        iconColor: const Color(0xFF18A665),
                        pillText: '...%',
                        pillBg: const Color(0xFFE5F8ED),
                        pillFg: const Color(0xFF18A665),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DashboardKpiCard(
                        title: 'Est. Profit',
                        value: currency.format(s.todaySales * 0.2),
                        unit: 'UGX',
                        icon: Icons.show_chart_rounded,
                        iconBg: const Color(0xFFEAF1FF),
                        iconColor: const Color(0xFF4A85F6),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 92,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Row(
                  children: const [
                    Expanded(child: Text('Failed to load dashboard.')),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              summary.when(
                data: (s) => Row(
                  children: [
                    Expanded(
                      child: DashboardKpiCard(
                        title: 'Low Stock',
                        value: '${s.lowStockCount}',
                        unit: 'Items',
                        icon: Icons.inventory_2_rounded,
                        iconBg: const Color(0xFFFFF2E4),
                        iconColor: const Color(0xFFE07A25),
                        pillText: 'Action',
                        pillBg: const Color(0xFFFFF2E4),
                        pillFg: const Color(0xFFE07A25),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: DashboardKpiCard(
                        title: 'Debts',
                        value: '0',
                        unit: 'People',
                        icon: Icons.account_balance_wallet_rounded,
                        iconBg: Color(0xFFFCE8E8),
                        iconColor: Color(0xFFD95050),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 92,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Row(
                  children: const [
                    Expanded(child: Text('')),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              notifications.when(
                data: (items) {
                  final unreadCount =
                      items.where((n) => n.readAt == null).length;
                  final top = items.take(3).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardSectionHeader(
                        title: 'NOTIFICATIONS',
                        actionText: 'View All',
                        actionColor: green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      if (unreadCount > 0)
                        Text(
                          '$unreadCount unread',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      if (unreadCount > 0) const SizedBox(height: 8),
                      if (top.isEmpty)
                        const Text(
                          'No notifications yet.',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                        )
                      else
                        NotebookListCard(
                          children: [
                            for (final (index, n) in top.indexed)
                              NotebookEntryRow(
                                data: NotebookEntryRowData(
                                  leadingIcon: Icons.notifications_none_rounded,
                                  leadingBg: const Color(0xFFF4F6F9),
                                  title: n.title,
                                  subtitle: n.message,
                                  trailing: DateFormat.Hm().format(
                                    n.createdAt.toLocal(),
                                  ),
                                ),
                                showDivider: index != top.length - 1,
                              ),
                          ],
                        ),
                      const SizedBox(height: 28),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              DashboardSectionHeader(
                title: 'RECENT SALES',
                actionText: 'View All',
                actionColor: green,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              recent.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Text(
                      'No activity yet. Record your first sale.',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                      ),
                    );
                  }
                  return NotebookListCard(
                    children: [
                      for (final (index, t) in items.indexed)
                        NotebookEntryRow(
                          data: NotebookEntryRowData(
                            leadingIcon: Icons.shopping_bag_rounded,
                            leadingBg: const Color(0xFFF4F6F9),
                            title: t.itemName,
                            subtitle:
                                '${DateFormat.Hm().format(t.timestamp)} • ${t.quantity} item${t.quantity == 1 ? '' : 's'}',
                            trailing: currency.format(t.amount),
                          ),
                          showDivider: index != items.length - 1,
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text(
                  'Failed to load recent sales.',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(height: 28),
              // const DashboardSectionHeader(
              //   title: 'STOCK IN',
              // ),
              // const SizedBox(height: 12),
              // NotebookListCard(
              //   children: [
              //     const NotebookEntryRow(
              //       data: NotebookEntryRowData(
              //         leadingIcon: Icons.local_shipping_rounded,
              //         leadingBg: Color(0xFFEAF1FF),
              //         leadingIconColor: Color(0xFF2563EB),
              //         title: 'Morning delivery',
              //         subtitle: '08:30 AM • 12 items',
              //         trailing: 'Restock',
              //         trailingIsLink: true,
              //       ),
              //       showDivider: false,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsAvatar extends StatelessWidget {
  const _NotificationsAvatar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _IconCircleButton(
          icon: Icons.notifications_none_rounded,
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/vector-1740737650825-1ce4f5377085?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 22),
      ),
    );
  }
}

