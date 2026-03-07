import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maneja/core/widgets/dashboard_widgets.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/services/api_insights_service.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final weeklyTrend = ref.watch(weeklyTrendProvider);
    final stock = ref.watch(stockProvider);

    final currency = NumberFormat.compactCurrency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FC),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            summary.when(
              data: (s) => DashboardKpiCard(
                title: 'Today sales',
                value: currency.format(s.todaySales),
                unit: 'UGX',
                icon: Icons.today_rounded,
                iconBg: const Color(0xFFE5F8ED),
                iconColor: const Color(0xFF18A665),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load insights.'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Weekly trend',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            weeklyTrend.when(
              data: (points) {
                if (points.isEmpty) {
                  return const _EmptyChart();
                }
                return _WeeklyTrendChart(points: points);
              },
              loading: () => const _ChartLoading(),
              error: (_, __) => const _ChartError(),
            ),
            const SizedBox(height: 18),
            const DashboardSectionHeader(
              title: 'LOW STOCK ALERTS',
            ),
            const SizedBox(height: 8),
            stock.when(
              data: (items) {
                final low = items.where((s) => s.quantity <= 5).toList();
                if (low.isEmpty) {
                  return const Text(
                    'All good. No low stock items.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  );
                }
                return NotebookListCard(
                  children: [
                    for (final (index, item) in low.indexed)
                      NotebookEntryRow(
                        data: NotebookEntryRowData(
                          leadingIcon: Icons.warning_amber_rounded,
                          leadingBg: const Color(0xFFFCE8E8),
                          leadingIconColor: const Color(0xFFD95050),
                          title: item.name,
                          subtitle: '${item.quantity} left',
                          trailing: 'Restock',
                          trailingIsLink: true,
                        ),
                        showDivider: index != low.length - 1,
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text(
                'Failed to load low stock.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.points});

  final List<WeeklyTrendPointDto> points;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));

    final maxTotal = sorted
        .map((p) => p.total)
        .fold<double>(0, (prev, v) => v > prev ? v : prev);

    String labelFor(DateTime d) => DateFormat('E').format(d);

    return Container(
      height: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            primary.withOpacity(0.10),
            primary.withOpacity(0.03),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (index, p) in sorted.indexed)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Bar(
                        value: p.total,
                        max: maxTotal <= 0 ? 1 : maxTotal,
                        color: primary.withOpacity(0.80 - (index * 0.05)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final p in sorted)
                Expanded(
                  child: Text(
                    labelFor(p.date),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.max,
    required this.color,
  });

  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / max).clamp(0.0, 1.0);
    final minFraction = value > 0 ? 0.06 : 0.0;
    final heightFactor = fraction == 0 ? 0.0 : (fraction < minFraction ? minFraction : fraction);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const Text(
        'Failed to load weekly trend.',
        style: TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const Text(
        'No data for this week yet.',
        style: TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}

